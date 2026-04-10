# To Graders:
This contains the database and other stuff from previous assignments

please go into ``/flights_app`` dir to see what I have from homework3, problem 1

## Containerized app build/run:
```bash
cd flights_app
docker compose up --build
```
then see localhost 3000.

destroy with
```bash
docker compose down --v
```

## local build/run
```bash
cd flights_app
bash reload.sh
```

the local build and run should work on a linux machine (I tested on ubuntu 22.04)

Please raise an issue if there is anything out of place.