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
| [POST `/api/v1/users`](#post-apiv1users) | creates a new user in the `users` table.|
| [PUT/PATCH `/api/v1/users/:id`](#putpatch-apiv1usersid) | updates information for a specific user |
| [DELETE  `/api/v1/users/:id`](#delete-apiv1usersid) | deletes a specific user from the database
| **Workouts** ||
| [GET `/api/v1/workouts`](#get-apiv1workouts) | gets an index of a user's workouts |
| [GET `/api/v1/workouts/:id`](#get-apiv1workoutsid) | gets a specific workout |
| [POST `/api/v1/workouts`](#post-apiv1workouts) | creates a new workout in the `workouts` table, as well as any dependent set structures in the `set_structures` table |
| [PUT/PATCH `/api/v1/workouts/:id`](#putpatch-apiv1workoutsid) | updates set structures associated with a workout |
| [DELETE `/api/v1/workouts/:id`](#delete-apiv1workoutsid) | delete a specific workout and its set structures |

## User Endpoints

### POST `/api/v1/users`

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
        "id": "<user's new ID>",
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

This endpoint allows authorized users to change any or all of the updatable user fields (currently, `first_name` and/or `last_name`). User's may *only* update their own accounts, as authorized by the `Authorization` header. 

#### REQUIRED HEADERS:
```json
{
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "<use's ID>"
}
```

#### REQUEST BODY:
```json
    {
        "first_name": "<new first name>",
        "last_name": "<new last name>"
    }
```

#### SUCCESSFUL RESPONSE:
`Status 200`

#### UNSUCCESSFUL RESPONSES:
`Status 401`
`Status 422`

---

### DELETE `/api/v1/users/:id/`

This endpoint allows authorized users to perminantly delete their account. User's may *only* delete their own accounts, as authorized by the `Authorization` header. 

#### REQUIRED HEADERS:
```json
{
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "<use's ID>"
}
```

#### SUCCESSFUL RESPONSE:
`Status 204`

#### UNSUCCESSFUL RESPONSES:
`Status 401`

---

## Workout Endpoints

### GET `/api/v1/workouts`

#### REQUIRED HEADERS:
```json
{
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "<User's ID>"
}
```

#### SUCCESSFUL RESPONSE:
`Status 200`
```JSON
{
    "data": [
        {
            "id": "1",
            "type": "workout",
            "attributes": {
                "completed_at": "Thursday, 04/03/2025, 06:38PM"
            },
            "relationships": {
                "set_structures": {
                    "data": []
                }
            }
        },
        {
            "id": "2",
            "type": "workout",
            "attributes": {
                "completed_at": "Thursday, 04/10/2025, 04:40AM"
            },
            "relationships": {
                "set_structures": {
                    "data": [
                        {
                            "id": "1",
                            "type": "set_structure"
                        }
                    ]
                }
            }
        },
    ]
}
```

#### UNSUCCESSFUL RESPONSE:

`Status 401`

---

### Get `/api/v1/workouts/:id`



#### SUCCESSFUL RESPONSE:

```json
{
    "data": {
        "id": "2",
        "type": "workout",
        "attributes": {
            "completed_at": "Thursday, 04/10/2025, 04:40AM"
        },
        "relationships": {
            "set_structures": {
                "data": [
                    {
                        "id": "1",
                        "type": "set_structure"
                    }
                ]
            }
        }
    },
    "included": [
        {
            "id": "1",
            "type": "set_structure",
            "attributes": {
                "sets": 3,
                "reps": 12,
                "name": "Leg Press",
                "resistance": "75 lbs"
            }
        }
    ]
}
```

#### UNSUCCESSFUL RESPONSES:
`Status 401`
`Status 404`

### POST `/api/v1/workouts`

#### REQUIRED HEADERS:

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "<User's ID>"
}
```

#### REQUEST BODY:

POST requests for new workouts should send both the workout and associated set structures in JSON:API format in the request body. 

Temporary IDs should be used for both the `workout` itself, as well as `set structures`. The preferred format for temporary IDs is a 4-digit hex, preceded by a `new_` prefix, for example: `new_a8289ae6`. However, this endpoint is tolerant of any ID strategy except for positive integers. Negative integers, UUIDs and other compliant strategies are acceptable. 

##### `exercise_id`

A `set structure`'s `exercise_id` should NOT be temporary, but should math the ID of an existing exercise in the Leg Day database. Exercises will be retrievable from the `/api/v1/exercises` endpoint after our next planned update. 

##### `resistance` and `resistance_unit`

These fields work together to track the amount of weight used during exercise. `resistance` should be sent as an integer. `resistance_unit` can represent one of two values - pounds or kilograms - and can be sent as either a string or an integer:

| Unit | String Notation | Integer Notation |
|---|:---:|:---:|
| pounds | "lbs" | 0 |
| Kilograms | "Kg" | 1 |

```json
{
    "data": {
        "id": "new_f7674236",
        "type": "workout",
        "attributes": {},
        "relationships": {
            "set_structures": {
                "data": [
                    {
                        "id": "new_023d5e76",
                        "type": "set_structure"
                    },
                    {
                        "id": "new_53d5f5e5",
                        "type": "set_structure"
                    }
                ]
            }
        }
    },
    "included": [
        {
            "id": "new_023d5e76",
            "type": "set_structure",
            "attributes": {
                "sets": "4",
                "reps": "10",
                "exercise_id": "5",
                "resistance": "100",
                "resistance_unit": "0"
            }
        },
        {
            "id": "new_53d5f5e5",
            "type": "set_structure",
            "attributes": {
                "sets": "3",
                "reps": "12",
                "exercise_id": "4",
                "resistance": "150",
                "resistance_unit": "Kg"
            }
        }
    ]
}
```

### SUCCESSFUL RESPONSE

`Status 201`

```json
{
    "data": {
        "id": "5",
        "type": "workout",
        "attributes": {
            "completed_at": "Monday, 04/14/2025, 04:12PM"
        },
        "relationships": {
            "set_structures": {
                "data": [
                    {
                        "id": "4",
                        "type": "set_structure"
                    },
                    {
                        "id": "5",
                        "type": "set_structure"
                    }
                ]
            }
        }
    },
    "included": [
        {
            "id": "4",
            "type": "set_structure",
            "attributes": {
                "sets": "4",
                "reps": "10",
                "name": "Leg Curl",
                "resistance": "100 lbs"
            }
        },
        {
            "id": "5",
            "type": "set_structure",
            "attributes": {
                "sets": "3",
                "reps": "12",
                "name": "Calf Raise",
                "resistance": "150 Kg"
            }
        }
    ]
}
```

#### UNSUCCESSFUL RESPONSES:
`Status 401`
`Status 422`

---

### PUT/PATCH `/api/v1/workouts/:id`

#### REQUIRED HEADERS:

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "123"
}
```

#### REQUEST BODY

The request body for workout update requests should follow the same conventions as posting a new workout, with a few differences.

The `workout` itself has no updatable fields - the `completed_at` field is set as the time it is saved to the database.

`set structure`s can be created, updated, or deleted from this endpoint:
* New `set structure`s should be sent with temporary IDs as described in the [POST `/api/v1/workouts`](#post-apiv1workouts) documentation.
* Existing `set_structures` should be sent with their given IDs - generating new temp IDs will cause duplication.
* Existing `set_structures` should be sent with an additional `delete` attribute, set to `true` or `false`. 
  * `set structure`s sent with `"delete": "false"` will be updated with attribute values sent in this request. 
  * `set structure`s sent with `"delete": "true"` will be perminantly deleted.

```json
{
    "data": {
        "id": "5",
        "type": "workout",
        "attributes": {
            "completed_at": "Monday, 04/14/2025, 04:12PM"
        },
        "relationships": {
            "set_structures": {
                "data": [
                    {
                        "id": "4",
                        "type": "set_structure"
                    },
                    {
                        "id": "5",
                        "type": "set_structure"
                    },
                    {
                        "id": "new_4709a681",
                        "type": "set_structure"
                    }
                ]
            }
        }
    },
    "included": [
        {
            "id": "4",
            "type": "set_structure",
            "attributes": {
                "sets": "4",
                "reps": "10",
                "exercise_id": "5",
                "resistance": "100",
                "resistance_unit": "0",
                "delete": "true"
            }
        },
        {
            "id": "5",
            "type": "set_structure",
            "attributes": {
                "sets": "4",
                "reps": "15",
                "exercise_id": "4",
                "resistance": "150",
                "resistance_unit": "0",
                "delete": "false"
            }
        },
        {
            "id": "new_4709a681",
            "type": "set_structure",
            "attributes": {
                "sets": "3",
                "reps": "12",
                "exercise_id": "4",
                "resistance": "150",
                "resistance_unit": "0"
            }
        }
    ]
}
```

#### SUCCESSFUL RESPONSE:
`Status 200`

```json
{
    "data": {
        "id": "5",
        "type": "workout",
        "attributes": {
            "completed_at": "Monday, 04/14/2025, 04:12PM"
        },
        "relationships": {
            "set_structures": {
                "data": [
                    {
                        "id": "5",
                        "type": "set_structure"
                    },
                    {
                        "id": "6",
                        "type": "set_structure"
                    }
                ]
            }
        }
    },
    "included": [
        {
            "id": "5",
            "type": "set_structure",
            "attributes": {
                "sets": "4",
                "reps": "15",
                "name": "Calf Raise",
                "resistance": "150 lbs"
            }
        },
        {
            "id": "6",
            "type": "set_structure",
            "attributes": {
                "sets": "3",
                "reps": "12",
                "name": "Squat",
                "resistance": "150 lbs"
            }
        }
    ]
}
```

#### UNSUCCESSFUL RESPONSES:
`Status 401`
`Status 404`
`Status 422`

---

## DELETE `/api/v1/workouts/:id`

This endpoint allows an authorized user to permenantly delete a `workout` and its associated `set structures`. Following RESTful architecture standards, the ID of the `workout` to be deleted is included in the URI. Authorization is included in the request header, in the form of the user's ID. 

#### REQUIRED HEADERS:

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "123"
}
```

#### SUCCESSFUL RESPONSE:

`Status 204`

#### UNSUCCESSFUL RESPONSES: 

`Status 404`
`Status 401`