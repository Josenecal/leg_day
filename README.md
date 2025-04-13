# Every Day Is Leg Day

Welcome to the Leg dAPI, a backend application that supports users planing and tracking their own workouts. The concept for this project came to me while I was working out in the gym, and realized that I couldn't for the life of me remember what weights I was using in my last workout. I realized that what I needed was a simple way to track my weight lifting workouts, and that having a database of different lifts at my fingertips wouldn't hurt either.

## Current State

This project is still under construction. Some features are not yet implemented, including
* JWT-based authentication and authorization (see docs for current auth strategy)
* Exercise-specific endpoints
* Proper JSON:API serialization of incoming / outgoing user data (see docs below)

## Local Setup

First, `fork` and `clone` this repository, then navigate to the cloned project directory.

This application is build with `Ruby on Rails 7.1.3`, using `Ruby 3.4.2`. To run it locally, ensure that you have `Ruby 3.4.2` installed and running. 

With rbenv:

``` bash
$ rbenv install 3.4.2
$ rbenv local 3.4.2
```

Or, with RVM: 

``` bash
$ rvm install 3.4.2
$ rvm use 3.4.2
```

Now, install the project dependencies: 

``` bash
$ bundle install
```

Ensure a PostgreSQL server is running, and initialize the database: 

``` bash
$ rails db:create
$ rails db:migrate
```

Run tests to validate that everything is working properly:

``` bash
$ bundle execute rspec
```

Finally, start the application: 

``` bash
$ rails s
```

## Usage
CRUD operations are supported with a few endpoints:


| **Users** | |
| :--- | :--- |
| [POST `/api/v1/users`](#post-`/api/v1/users/`) | creates a new user in the `users` table.|
| PATCH `/api/v1/users/:id` | updates information for a specific user |
| DELETE  `/api/v1/users/:id` | deletes a specific user from the database
| **Workouts** ||
| GET `/api/v1/workouts` | gets an index of a user's workouts |
| GET `/api/v1/workouts/:id` | gets a specific workout |
| POST `/api/v1/workouts` | creates a new workout in the `workouts` table, as well as any dependent set structures in the `set_structures` table |
| PUT/PATCH `/api/v1/workouts/:id` | updates set structures associated with a workout |
| DELETE `/api/v1/workouts/:id` | delete a specific workout and its set structures |

## User Endpoints

### POST `/api/v1/user`

#### REQUIRED HEADERS:
```json
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

#### REQUEST BODY:
```json
    {
        "first_name": "<user's first name>",
        "last_name": "<user's last name>",
        "email": "<user's email>",
        "password": "<user's desired password>"

    }
```

#### SUCCESSFUL RESPONSE:
`Status 201`
```JSON
{
    "data": {
        "id": "<user's new ID">,
        "type": "user",
        "attributes": {
            "first_name": "<user's first name>",
            "last_name": "<user's last name>",
            "email": "<user's email>"
        }
    }
}
```

#### UNSUCCESSFUL RESPONSE:

`Status 422`

---

### PUT/PATCH `/api/v1/users/:id/`
## Application Architecture

Leg dAPI is backed by a PostgreSQL database with a very simple layout: 

![image](/readme_resources/db_diagram.png)