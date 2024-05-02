-- DateDiff function that returns the difference between two timestamps in the given date_part (weeks, months, etc) as an integer
-- This behaves like the DateDiff function in warehouses like Redshift and Snowflake, which count the boundaries between date_parts
-- based in https://www.narratordata.com/blog/postgres-missing-datediff-function/
CREATE OR REPLACE FUNCTION datediff (date_part VARCHAR(30), start_t TIMESTAMP, end_t TIMESTAMP)
  RETURNS INT AS $diff$

  DECLARE
    years INT = 0;
    days INT = 0;
    hours INT = 0;
    minutes INT = 0;  
  BEGIN

    -- year is straightforward. Convert to an integer representing the year and subtract
    years = DATE_PART('year', end_t) - DATE_PART('year', start_t);

    IF date_part IN ('y', 'yr', 'yrs', 'year', 'years')  THEN
      RETURN years;
    END IF;

    -- quarter and month use integer math: count years, multiply to convert to quarters or months
    -- as an integer and then subtract

    IF date_part IN ('quarter', 'quarters', 'qtr', 'qtrs')  THEN
      RETURN years * 4 + (DATE_PART('quarter', end_t) - DATE_PART('quarter', start_t)); 
    END IF;

    IF date_part IN ('month', 'months', 'mon', 'mons')  THEN
      RETURN years * 12 + (DATE_PART('month', end_t) - DATE_PART('month', start_t)); 
    END IF;


    -- Weeks only fit evenly in days.  
    -- Truncate by week (which returns the start of the first day of the week)
    -- then subtract by days.
    IF date_part IN ('week', 'weeks', 'w') THEN
      RETURN DATE_PART('day', (DATE_TRUNC('week', end_t) - DATE_TRUNC('week', start_t)) / 7);
    END IF;


    -- Day is similar to week. Truncate to beginning of day so that we can diff whole days
    days = DATE_PART('day', DATE_TRUNC('day', end_t) - DATE_TRUNC('day', start_t));

    IF date_part IN ('day', 'days', 'd') THEN
      RETURN days;
    END IF;
    
    -- hours, minutes, and seconds all just build up from each other
    hours = days * 24 + (DATE_PART('hour', end_t) - DATE_PART('hour', start_t));

    IF date_part IN ('hour', 'hours', 'h', 'hr', 'hrs') THEN
      RETURN hours;
    END IF;


    minutes = hours * 60 + (DATE_PART('minute', end_t) - DATE_PART('minute', start_t));

    IF date_part IN ('minute', 'minutes', 'm', 'min', 'mins') THEN
      RETURN minutes;
    END IF;


    IF date_part IN ('second', 'seconds', 's', 'sec', 'secs') THEN
      RETURN minutes * 60 + (DATE_PART('second', end_t) - DATE_PART('second', start_t));
    END IF;


    RETURN 0;
END;
$diff$ LANGUAGE plpgsql;