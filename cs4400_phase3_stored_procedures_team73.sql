-- CS4400: Introduction to Database Systems: Tuesday, September 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;

drop procedure if exists get_passengers;
delimiter //
create procedure get_passengers (in ip_flightId varchar(50))
sp_main: begin
    select personID
    from flight
    join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
    where flightID = ip_flightId;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin

    INSERT INTO location (locationID)
        VALUES (ip_locationID);

    INSERT INTO airplane (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, skids, propellers, jet_engines)
        VALUES (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);

end //

delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

    INSERT INTO location (locationID)
        VALUES (ip_locationID);

    INSERT INTO airport (airportID, airport_name, city, state, country, locationID)
        VALUES (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);

end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin

    INSERT INTO person (personID, first_name, last_name, locationID)
        VALUES (ip_personID, ip_first_name, ip_last_name, ip_locationID);

    IF ip_taxID THEN

        # is a pilot
        INSERT INTO pilot (personID, taxID, experience, commanding_flight)
            VALUES (ip_personID, ip_taxID, ip_experience, null);

        ELSE

        # is a passenger
        INSERT INTO passenger (personID, miles, funds)
            VALUES (ip_personID, ip_miles, ip_funds);

    END IF;

end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it laready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

    IF (EXISTS(select * from pilot_licenses where personID = ip_personID and license = ip_license)) THEN

        # if there is already a license, revoke
        DELETE FROM pilot_licenses
            WHERE license = ip_license AND personID = ip_personID;

    ELSE

        # no license
        INSERT INTO pilot_licenses (personID, license)
            VALUES (ip_personID, ip_license);

    END IF;

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
    DECLARE is_last_route BOOLEAN;

    IF (ip_support_tail IS NOT NULL) THEN

        # check if the flight is in use
        IF (EXISTS(SELECT * FROM flight
                    WHERE support_airline = ip_support_airline
                        AND support_tail = ip_support_tail
                        AND progress = 'in_flight')) THEN

            LEAVE sp_main;

        END IF;

    END IF;

    # check if the current route is the last in the journey
    SET is_last_route = (SELECT max(sequence) FROM route_path WHERE routeID = ip_routeID) = ip_progress;

    IF is_last_route THEN
        LEAVE sp_main;
    END IF;

    INSERT INTO flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time, cost)
        VALUES (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);

end //
delimiter ;

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
DECLARE miles_on_leg INTEGER;

SET miles_on_leg = (select distance
                    from flight
                    join route_path rp on flight.routeID = rp.routeID and rp.sequence = flight.progress 
                    join leg l on rp.legID = l.legID
                    where flightID = ip_flightID);

if((select airplane_status from flight where flightID = ip_flightID) = 'on_ground' ) THEN
    LEAVE sp_main;
END IF;

    update flight set airplane_status = 'on_ground',
    next_time = addtime(next_time, '1:00:00')  
    where flightID = ip_flightID;

    update pilot set experience = experience + 1 
    where personID in (select personID from (select * from pilot) as pain where commanding_flight = ip_flightID);

    update passenger
    set miles = miles + miles_on_leg
    where personID in (select personID from flight join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num where flightID = ip_flightID);
end //
delimiter ;

-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

# first ensure that prop planes have one pilot and jet have two
DECLARE pilot_count INTEGER;
DECLARE plane_type VARCHAR(50);

DECLARE miles_on_leg INTEGER;
DECLARE plane_speed INTEGER;
DECLARE time_delta TIME;
declare has_flight_ended boolean;

SET pilot_count = (SELECT COUNT(*) FROM pilot WHERE commanding_flight = ip_flightID);
SET plane_type = (SELECT plane_type
                    FROM flight
                    JOIN airplane a on a.airlineID = flight.support_airline and a.tail_num = flight.support_tail
                    WHERE flight.flightID = ip_flightID);
SET plane_speed = (SELECT speed
                    FROM flight
                    JOIN airplane a on a.airlineID = flight.support_airline and a.tail_num = flight.support_tail
                    WHERE flight.flightID = ip_flightID);

SET has_flight_ended = (select progress
                        from flight
                        where flightID = ip_flightID) = (select max(sequence) from flight
                            join route_path rp on flight.routeID = rp.routeID where flightID = ip_flightID)
						and
                       (select airplane_status
                        from flight
                        where flightID = ip_flightID) = 'on_ground';

if(has_flight_ended) THEN
    LEAVE sp_main;
END IF;

if( ip_flightID not in (select flightID from flight)) THEN
    LEAVE sp_main;
END IF;

if((select airplane_status from flight where flightID = ip_flightID) = 'in_flight' ) THEN
    LEAVE sp_main;
END IF;


# if it is a jet, make sure that there is at least 2 pilot
IF (plane_type = 'jet' AND pilot_count < 2) OR (plane_type = 'prop' AND pilot_count < 1) THEN
    # delay flight
    UPDATE flight
    SET next_time = addtime(next_time, '00:00:30');

    LEAVE sp_main;
END IF;

# compute the time needed to travel the leg
SET miles_on_leg = (select distance
                    from flight
                    join route_path rp on flight.routeID = rp.routeID and rp.sequence = flight.progress + 1
                    join leg l on rp.legID = l.legID
                    where flightID = ip_flightID);



# take off by setting the current status to 'in_flight'
UPDATE flight
SET airplane_status = 'in_flight',
progress = progress + 1,
next_time = addtime(next_time, leg_time(miles_on_leg,plane_speed))
WHERE flightID = ip_flightID;

end //
delimiter ;

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	declare number_of_passengers integer;
    declare plane_capacity integer;
    declare flight_cost integer;
    declare miles_traveled integer;
    declare plane_loc varchar(50);
    declare flight_dest varchar(50);
    declare grounded boolean;
    declare passenger_vacation_dest_count integer;
    declare has_flight_ended boolean;

    set has_flight_ended = (select progress
                        from flight
                        where flightID = ip_flightID) = (select max(sequence) from flight
                            join route_path rp on flight.routeID = rp.routeID where flightID = ip_flightID)
						and
                       (select airplane_status
                        from flight
                        where flightID = ip_flightID) = 'on_ground';

    set grounded = ((select airplane_status from flight where flightID = ip_flightId) = 'on_ground' );

    set plane_capacity = (select seat_capacity
                            from flight
                            join airplane a on flight.support_airline = a.airlineID and flight.support_tail = a.tail_num
                            where flightID = ip_flightID);

	set miles_traveled = (select distance
                            from flight
                            join route_path rp on flight.routeID = rp.routeID and sequence = progress +1
                            join leg l on rp.legID = l.legID
                            where flightID = ip_flightID);

	set flight_cost = (select cost
                        from flight
                        where flightID = ip_flightID);

    set flight_dest = (select a.airportID as 'AirportId'
                        from flight
                        join route_path rp on flight.routeID = rp.routeID and rp.sequence  = flight.progress + 1
                        join leg l on rp.legID = l.legID
                        join airport a on l.arrival = a.airportID
                        where flightID = ip_flightID);

	set plane_loc = (select locationID
                            from flight
                            join airplane a on flight.support_airline = a.airlineID and flight.support_tail = a.tail_num
                            where flightID = ip_flightID);

    set number_of_passengers = (select count(*)
                                from flight
                                join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
                                where flightID = ip_flightId and funds >= cost and locationID = plane_loc);

	set passenger_vacation_dest_count = (
            select distinct count(*)
            from passenger_vacations
            where
                -- get a list of passengers ids
                passenger_vacations.personID in (select temp2.personID
                                from flight
                                join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
                                where flightID = ip_flightId)
                and airportID in (select a.airportID as 'AirportId'
									from flight
									join route_path rp on flight.routeID = rp.routeID and rp.sequence  > flight.progress
									join leg l on rp.legID = l.legID
									join airport a on l.arrival = a.airportID
									where flightID = 'ja_35')  and sequence = 1);


    # not enough seats for all the passengers
    if (number_of_passengers > plane_capacity) then
        leave sp_main;
    end if;

    -- checks if plane is grounded
    if (!grounded or !has_flight_ended) then
        leave sp_main;
    end if;

     if (passenger_vacation_dest_count != number_of_passengers) then
        leave sp_main;
    end if;

    update passenger
    join person p on passenger.personID = p.personID
    set miles = miles + miles_traveled, p.locationID = plane_loc, funds = funds - flight_cost
    where passenger.personID in (
        select temp2.personID
        from flight
        join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
        where flightID = ip_flightId
    );

end //
delimiter ;

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
DECLARE airport_loc_id VARCHAR(50);
    declare has_flight_taken_off boolean;
    set has_flight_taken_off = (not exists(
        select *
        from flight
        where progress = 0 and flightID = ip_flightID
        ));

    if (not has_flight_taken_off) then
        leave sp_main;
    end if;

    # we would like to know which airport they have landed and the location id of that airport
    SET airport_loc_id = (select a.locationID as 'Destination Location Id'
                            from flight
                            join route_path rp on flight.routeID = rp.routeID and flight.progress = rp.sequence
                            join leg l on rp.legID = l.legID
                            join airport a on l.arrival = a.airportID
                            where flightID = ip_flightID);

    update passenger
    join person p on p.personID = passenger.personID
    set p.locationID = airport_loc_id
    where passenger.personID in (
        select personID
        from passenger_vacations
        where
            -- get a list of passengers ids
            passenger_vacations.personID in (select temp2.personID
                            from flight
                            join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
                            where flightID = ip_flightID)
            and airportID = (select a.airportID as 'Destination Location Id'
                            from flight
                            join route_path rp on flight.routeID = rp.routeID and flight.progress = rp.sequence
                            join leg l on rp.legID = l.legID
                            join airport a on l.arrival = a.airportID
                            where flightID = ip_flightID)
            and sequence = 1
    );

    DELETE FROM passenger_vacations
    WHERE
        personID IN (
            SELECT personID FROM (
                SELECT pv.personID
                FROM passenger_vacations pv
                WHERE
                    pv.personID IN (
                        SELECT temp2.personID
                        FROM flight
                        JOIN (
                            SELECT *
                            FROM airplane
                            NATURAL JOIN (
                                SELECT *
                                FROM passenger
                                NATURAL JOIN person
                            ) AS temp1
                        ) AS temp2 ON support_tail = temp2.tail_num
                        WHERE flightID = ip_flightID
                    )
                    AND pv.airportID = (
                        SELECT a.airportID
                        FROM flight
                        JOIN route_path rp ON flight.routeID = rp.routeID AND flight.progress = rp.sequence
                        JOIN leg l ON rp.legID = l.legID
                        JOIN airport a ON l.arrival = a.airportID
                        WHERE flightID = ip_flightID
                    )
                    AND pv.sequence = 1
            ) AS subquery
        )
    AND sequence = 1;

end //
delimiter ;

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

-- checks
declare pilot_location varchar(50);
declare plane_location varchar(50);

declare plane_type varchar(50);

-- if pilot is assigned to another flight, abort
IF ((select commanding_flight from pilot where personID = ip_personID) is not null) then
    leave sp_main;
end if;

-- if the pilot doesn't own a license for the plane type, abort
set plane_type = (SELECT plane_type
                    FROM flight
                    JOIN airplane a on a.airlineID = flight.support_airline and a.tail_num = flight.support_tail
                    WHERE flight.flightID = ip_flightID);

if (not exists(select * from pilot_licenses where personID = ip_flightID and license = plane_type)) then
    leave sp_main;
end if;

-- if pilot is not in the same location as the plane he is about to command, abort
set pilot_location = (select locationID
                    from pilot
                    join person p on pilot.personID = p.personID);

set plane_location = (select departure
                        from flight
                        join route_path rp on flight.routeID = rp.routeID and flight.progress = rp.sequence
                        join leg l on rp.legID = l.legID
                        where flightID = ip_flightID);

if (pilot_location != plane_location) then
    leave sp_main;
end if;

-- finally, we assign the pilot to the flight and then update the pilots location as the plane location
update pilot
set commanding_flight = ip_flightID
where personID = ip_personID;

update pilot
join person p2 on p2.personID = pilot.personID
set p2.locationID = (
    select locationID
    from flight
    join airplane a on flight.support_airline = a.airlineID and flight.support_tail = a.tail_num
    where flight.flightID = ip_flightID)
where pilot.personID = ip_flightID;

end //
delimiter ;
-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

# check if the flight has ended
declare has_flight_ended boolean;
declare last_leg_sequence_no integer;

declare has_all_passengers_disembarked boolean;

declare flight_landing_location varchar(50);

set last_leg_sequence_no = (select max(sequence)
                            from flight
                            join route_path rp on flight.routeID = rp.routeID
                            where flightID = ip_flightID);

set has_flight_ended = (select progress
                        from flight
                        where flightID = ip_flightID) = last_leg_sequence_no and
                       (select airplane_status
                        from flight
                        where flightID = ip_flightID) = 'on_ground';

set flight_landing_location = (select a.locationID
                                from flight
                                join route_path rp on flight.routeID = rp.routeID and sequence = progress
                                join leg l on rp.legID = l.legID
                                join airport a on l.arrival = a.airportID
                                where flightID = ip_flightID);

if (not has_flight_ended) then
    leave sp_main;
end if;

set has_all_passengers_disembarked = (not exists(select * from flight
									join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
									where flightID = ip_flightId and locationID != flight_landing_location));

if (not has_all_passengers_disembarked) then
    leave sp_main;
end if;

# update all pilots for a plane to be the airport
update pilot
join person p on p.personID = pilot.personID
set p.locationID = flight_landing_location, commanding_flight = null
where commanding_flight = ip_flightID;

end //
delimiter ;

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
# check if the flight has ended
declare has_flight_ended boolean;
declare last_leg_sequence_no integer;
declare start_leg boolean;
declare has_all_passengers_disembarked boolean;
declare has_all_pilots_disembarked boolean;
declare flight_landing_location varchar(50);

set last_leg_sequence_no = (select max(sequence)
                            from flight
                            join route_path rp on flight.routeID = rp.routeID
                            where flightID = ip_flightID);

set start_leg = 0;

set has_flight_ended = (select progress
                        from flight
                        where flightID = ip_flightID) = last_leg_sequence_no
                        or
                        (select progress 
                        from flight
                        where flightID = ip_flightID) = start_leg 
                        and
                       (select airplane_status
                        from flight
                        where flightID = ip_flightID) = 'on_ground';

if (not has_flight_ended) then
    leave sp_main;
end if;
                        
set flight_landing_location = (select a.locationID
                                from flight
                                join route_path rp on flight.routeID = rp.routeID and sequence = progress
                                join leg l on rp.legID = l.legID
                                join airport a on l.arrival = a.airportID
                                where flightID = ip_flightID);
                                
set has_all_passengers_disembarked = (not exists(select * from flight
									join (select * from airplane natural join (select * from passenger natural join person) as temp1) as temp2 on support_tail = temp2.tail_num
									where flightID = ip_flightId and locationID != flight_landing_location));

set has_all_pilots_disembarked = (not exists(select * from flight
									join (select * from airplane natural join (select * from passenger natural join pilot) as temp1) as temp2 on support_tail = temp2.tail_num
									where flightID = ip_flightId and locationID != flight_landing_location));
                                    
if (not has_all_passengers_disembarked or not has_all_pilots_disembarked) then
    leave sp_main;
end if;

delete from flight where flightID = ip_flightID;

end //
delimiter ;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin
DECLARE smallest_time TIME;
DECLARE count_of_flights integer;
DECLARE ip_flightID varchar(50);
DECLARE grounded boolean;
DECLARE flying boolean;
DECLARE has_flight_ended boolean;
DECLARE last_leg_sequence_no integer;


SET smallest_time = (select min(next_time) from flight);
SET count_of_flights = (SELECT count(*) from flight where next_time = smallest_time);
SET grounded = (exists (select airplane_status from flight where airplane_status = 'on_ground' and next_time = smallest_time));
SET flying = (exists (select airplane_status from flight where airplane_status = 'in_flight' and next_time = smallest_time));

                        
if (count_of_flights = 0) then
	leave sp_main;
end if;

if (count_of_flights = 1) then
	SET ip_flightID = (select flightID from flight where next_time = smallest_time);
end if;

-- if multiple prefer the flights in the air over grounded then if there is still more than one then prefer the first on in alphebitcal order
if (count_of_flights > 1) then
	if(grounded) then
		SET ip_flightID = (select distinct first_value(flightID) OVER (order by flightID asc) from flight where airplane_status = 'on_ground');
	end if;
	if (!grounded and flying) then
		SET ip_flightID = (select distinct first_value(flightID) OVER (order by flightID asc) from flight where airplane_status = 'in_flight');
	end if;
end if;


SET last_leg_sequence_no = (select max(sequence)
                            from flight
                            join route_path rp on flight.routeID = rp.routeID
                            where flightID = ip_flightID);

SET has_flight_ended = (select progress
                        from flight
                        where flightID = ip_flightID) = last_leg_sequence_no
                        and
                       (select airplane_status
                        from flight
                        where flightID = ip_flightID) = 'on_ground';
                        



-- if in flight getting ready to ground, should land, passenger disembark and time should be advanced by 1 hour time advancmeent in passenger dissembark
if ((select airplane_status from flight where flightID = ip_flightID) = 'in_flight') then
	CALL flight_landing(ip_flightID);
    CALL passengers_disembark(ip_flightID);
    leave sp_main;
end if;

-- if on ground getting ready to take off passengers board, time advance covered in takeoff
if ((select airplane_status from flight where flightID = ip_flightID) = 'on_ground' and !has_flight_ended) then
	CALL passengers_board(ip_flightID);
    CALL flight_takeoff(ip_flightID);
    leave sp_main;
end if;

-- if airplane on ground and reached the end it should recycle flight and retire flight
if (has_flight_ended) then
	CALL recycle_crew(ip_flightID);
    CALL retire_flight(ip_flightID);
    leave sp_main;
end if;

end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select departure, arrival, count(*), GROUP_CONCAT(flightID separator ','), min(next_time), max(next_time), GROUP_CONCAT(locationID separator ',') 
from (select * from leg natural join (select * from route_path natural join (select tail_num, locationID, flightID, routeID, progress, next_time from airplane join (select * from flight where airplane_status = 'in_flight') as A on support_tail = tail_num) as B where progress = sequence) as C) 
as D 
group by legID;


-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select update_progress, count(*), GROUP_CONCAT(flightID separator ','), min(next_time), max(next_time), GROUP_CONCAT(locationID separator ',') 
from (select IF(check_first = 0.5, departure, arrival) as update_progress, locationID, flightID, next_time from (select C.legID, departure, arrival, routeID, sequence, support_tail, flightID, check_first, next_time, locationID from leg, (select B.routeID, legID, sequence, support_tail, flightID, check_first, next_time, locationID from route_path, (select support_tail, flightID, routeID, IF(progress = 0, 0.5, progress) as check_first, next_time, locationID from flight natural join (select tail_num as support_tail, seat_capacity, speed, locationID, plane_type, skids, propellers, jet_engines from airplane) as A where airplane_status = 'on_ground') as B where B.routeID = route_path.routeID) as C where C.legID = leg.legID) as D where IF(check_first = 0.5, 1, check_first) = sequence) 
as E 
group by update_progress;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select departure, arrival, count(distinct locationID), GROUP_CONCAT(distinct locationID separator ','), GROUP_CONCAT(distinct flightID separator ','), min(next_time), max(next_time), count(taxID), count(D.personID) - count(taxID), count(D.personID), GROUP_CONCAT(distinct D.personID separator ',') from pilot right join (
select * from person natural join (
select legID, departure, arrival, routeID, sequence, flightID, next_time, locationID from leg natural join (
select * from route_path natural join (
select * from flight join airplane on support_tail = tail_num where airplane_status = 'in_flight') as A where progress = sequence) as B) as C) as D on pilot.personID = D.personID group by departure, arrival;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airportID, locationID, airport_name, city, state, country, count(taxID), count(personID) - count(taxID), count(personID), GROUP_CONCAT(personID separator ',')
from airport natural join (
select person.personID, locationID, taxID from pilot right join person on pilot.personID = person.personID where locationID like '%port%') as A group by airportID;

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
    num_flights, flight_list, airport_sequence) as
select r.routeID,
       count(distinct legID),
       GROUP_CONCAT(distinct legID order by r.routeID, sequence separator ','),
       if(count(distinct f.flightID) > 0, FLOOR((sum(l.distance) / count(distinct f.flightID))) , sum(l.distance)),
       count(distinct f.flightID),
       group_concat(distinct f.flightID),
       GROUP_CONCAT(distinct CONCAT(departure,'->',arrival) order by r.routeID, sequence separator ',')
from route_path r
natural join leg l
left join flight f on r.routeID = f.routeID
group by routeID;


-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select city, state, country, airport_count, group_concat(airportID) as 'airport_code_list', group_concat(airport_name) as 'airport_name_list'
from airport a
inner join (
select concat(city, state, country) as state_country, count(*) as airport_count
from airport
group by concat(city, state, country)
having COUNT(*) > 1) as grouped_airports on concat(city, state, country) = grouped_airports.state_country
group by city, state, country, airport_count;