DROP TABLE IF EXISTS FREELANCER;
DROP TABLE IF EXISTS FREELANCER_SKILLS;
CREATE TABLE FREELANCER (
  id integer PRIMARY KEY,
  firstname varchar(50),
  lastname varchar(50),
  email varchar(50)
);
CREATE TABLE FREELANCER_SKILLS (
  id SERIAL PRIMARY KEY,
  skill varchar(50),
  detail varchar(100),
  freelancer_id integer,
  FOREIGN KEY (freelancer_id) REFERENCES freelancer(id)
);


