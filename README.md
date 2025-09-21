# Every Day Is Leg Day

Welcome to the Leg dAPI, a backend application that supports users planing and tracking their own workouts. The concept for this project came to me while I was working out in the gym, and realized that I couldn't for the life of me remember what weights I was using in my last workout. I realized that what I needed was a simple way to track my weight lifting workouts, and that having a database of different lifts at my fingertips wouldn't hurt either.

## Attributions

### Clint Plummer: `free-exercise-db`
Special thanks go out to [Clint Plummer](https://github.com/yuhonas) for contributing an open-source, public-domain dataset of exercises in the [Free Exercise Database](https://github.com/yuhonas/free-exercise-db/). This dataset was used to seed the original 873 exercises in the Leg Day database, and are a critical contribution without wich the Leg Day project simply would not be possible. 

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
| [POST `/api/v1/users`](#post-apiv1users) | Creates a new user in the `users` table.|
| [PUT/PATCH `/api/v1/users/:id`](#putpatch-apiv1usersid) | Updates information for a specific user. |
| [DELETE  `/api/v1/users/:id`](#delete-apiv1usersid) | Deletes a specific user from the database. |
| **Workouts** ||
| [GET `/api/v1/workouts`](#get-apiv1workouts) | Gets an index of a user's workouts. |
| [GET `/api/v1/workouts/:id`](#get-apiv1workoutsid) | Gets a specific workout. |
| [POST `/api/v1/workouts`](#post-apiv1workouts) | Creates a new workout in the `workouts` table, as well as any dependent set structures in the `set_structures` table. |
| [PUT/PATCH `/api/v1/workouts/:id`](#putpatch-apiv1workoutsid) | Updates set structures associated with a workout. |
| [DELETE `/api/v1/workouts/:id`](#delete-apiv1workoutsid) | Delete a specific workout and its set structures. |
| **Exercises** ||
| [GET `/api/v1/exercises`](#get-apiv1exercises) | Gets a paginated list of all exercises in JSON format. |
| [GET `/api/v1/exercises/:id`](#get-apiv1exercisesid) | Shows a specific exercise in detail. |
| **Authentication** ||
| [POST `/api/v1/auth`](#post-apiv1auth) | Returns a JWT when passed a valid email and password. |

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

### DELETE `/api/v1/workouts/:id`

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

---

## Exercises

### GET `/api/v1/exercises`

This endpoint will provide an index of all exercises in the database. By default, the response is paginated with 20 items per page. The JSON response will include top-level `meta` and `links` objects to support front-end pagination. The endpoint itself will accept a `page` query param to support navigation.

No authorization is necessary to access this endpoint.

#### REQUIRED HEADERS

```JSON
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

#### PAGINATION QUERY PARAMS

| key | value | constraints |
| --- | --- | --- |
| page | 1,2,3...n | page number must be between 1 and the total number of pages (see metadata["total_pages"])

#### SEARCH PARAMS

| key | value | constraints |
| --- | --- | --- |
| `name` | any string | must be URI-encoded |
| `category` | current values include: "strength", "stretching", "plyometrics", "strongman", "powerlifting", "cardio", and "olympic weightlifting" | searching for other values will return an empty result. |
| `level` | current values include: "beginner", "intermediate", and "expert" | searching for other values will return an empty result. |



#### SUCCESFUL RESPONSE

```JSON
{
    "data": [
        {
            "id": "1",
            "type": "exercise",
            "attributes": {
                "name": "3/4 Sit-Up",
                "category": "strength",
                "equipment": [
                    "body only"
                ],
                "level": "beginner",
                "mechanic": "compound",
                "force": null,
                "primary_muscles": [
                    "abdominals"
                ],
                "secondary_muscles": [],
                "instructions": [
                    "Lie down on the floor and secure your feet. Your legs should be bent at the knees.",
                    "Place your hands behind or to the side of your head. You will begin with your back on the ground. This will be your starting position.",
                    "Flex your hips and spine to raise your torso toward your knees.",
                    "At the top of the contraction your torso should be perpendicular to the ground. Reverse the motion, going only ¾ of the way down.",
                    "Repeat for the recommended amount of repetitions."
                ]
            }
        },

        ...

        {
            "id": "234",
            "type": "exercise",
            "attributes": {
                "name": "Dumbbell Lying Supination",
                "category": "strength",
                "equipment": [
                    "dumbbell"
                ],
                "level": "intermediate",
                "mechanic": "isolation",
                "force": null,
                "primary_muscles": [
                    "forearms"
                ],
                "secondary_muscles": [],
                "instructions": [
                    "Lie sideways on a flat bench with one arm holding a dumbbell and the other hand on top of the bench folded so that you can rest your head on it.",
                    "Bend the elbows of the arm holding the dumbbell so that it creates a 90-degree angle between the upper arm and the forearm.",
                    "Now raise the upper arm so that the forearm is parallel to the floor and perpendicular to your torso (Tip: So the forearm will be directly in front of you). The upper arm will be stationary by your torso and should be parallel to the floor (aligned with your torso at all times). This will be your starting position.",
                    "As you breathe out, externally rotate your forearm so that the dumbbell is lifted up in a semicircle motion as you maintain the 90 degree angle bend between the upper arms and the forearm. You will continue this external rotation until the forearm is perpendicular to the floor and the torso pointing towards the ceiling. At this point you will hold the contraction for a second.",
                    "As you breathe in, slowly go back to the starting position.",
                    "Repeat for the recommended amount of repetitions and then switch to the other arm."
                ]
            }
        }
    ],
    "meta": {
        "current_page": 1,
        "total_pages": 5,
        "total_items": 93,
        "per_page": 20
    },
    "links": {
        "self": "http://localhost:3000/api/v1/exercises?page=1",
        "first": "http://localhost:3000/api/v1/exercises?page=1",
        "last": "http://localhost:3000/api/v1/exercises?page=5",
        "prev": null,
        "next": "http://localhost:3000/api/v1/exercises?page=2"
    }
}
```

#### UNSUCCESSFUL RESPONSE
`Status 500`

---
### GET `/api/v1/exercises/:id`

This endpoint allows users to request detailed information about 1 exercise by adding its specific ID. 

#### REQUIRED HEADERS

```JSON
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

#### SUCCESSFUL RESPONSE

```JSON
{
    "data": {
        "id": "1",
        "type": "exercise",
        "attributes": {
            "name": "3/4 Sit-Up",
            "category": "strength",
            "equipment": [
                "body only"
            ],
            "level": "beginner",
            "mechanic": "compound",
            "force": null,
            "primary_muscles": [
                "abdominals"
            ],
            "secondary_muscles": [],
            "instructions": [
                "Lie down on the floor and secure your feet. Your legs should be bent at the knees.",
                "Place your hands behind or to the side of your head. You will begin with your back on the ground. This will be your starting position.",
                "Flex your hips and spine to raise your torso toward your knees.",
                "At the top of the contraction your torso should be perpendicular to the ground. Reverse the motion, going only ¾ of the way down.",
                "Repeat for the recommended amount of repetitions."
            ]
        }
    }
}
```

#### UNSUCCESSFUL RESPONSE
`Status 404`
`Status 500`

## Authentication

### POST `/api/v1/auth`

This endpoint will provide an index of all exercises in the database. By default, the response is paginated with 20 items per page. The JSON response will include top-level `meta` and `links` objects to support front-end pagination. The endpoint itself will accept a `page` query param to support navigation.

No authorization is necessary to access this endpoint.

#### REQUIRED HEADERS

```JSON
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

#### REQUEST BODY

The request body should be sent in JSON format, and must contain valid `email` and `password` properties at the root level:

```json
{
    "email": "my@email.com",
    "Password": "my_password"
}
```


#### SUCCESSFUL RESPONSE

```json
{
    "status": 200,
    "code": "OK",
    "message": "Authentication Successful",
    "token": "example123.json456.token789"
}
```

#### UNSUCCESSFUL RESPONSES

```json
    {
        "status": 401,
        "code": "UNAUTHORIZED",
        "message": "Authentican Failed",
        "details": "The email and password provided do not match"
    }
```