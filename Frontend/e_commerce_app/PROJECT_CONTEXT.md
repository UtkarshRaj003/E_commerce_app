# PROJECT CONTEXT – ECOMMERCE FRONTEND

This is a Flutter ecommerce frontend application.

IMPORTANT:

* Backend is already built using Node.js, Express, MongoDB
* Frontend must ONLY consume APIs
* Do NOT create backend logic
* Always use real API calls (no dummy data)

---

## BACKEND CONFIG

Base URL:
http://10.0.2.2:5000/api

---

## AUTH APIs

POST /auth/register
Request:
{
"name": "string",
"email": "string",
"password": "string"
}

Response:
{
"token": "jwt_token",
"user": {
"_id": "string",
"name": "string",
"email": "string"
}
}

---

POST /auth/login
Request:
{
"email": "string",
"password": "string"
}

Response:
{
"token": "jwt_token",
"user": {
"_id": "string",
"name": "string",
"email": "string"
}
}

---

## PRODUCT APIs

GET /products

Response:
[
{
"_id": "string",
"title": "string",
"description": "string",
"price": 100,
"images": ["image_url"],
"categoryId": "string"
}
]

---

## HEADERS

For protected routes:
Authorization: Bearer <token>

---

## TECH STACK (FRONTEND)

* Flutter
* BLoC (flutter_bloc)
* Dio (for API calls)
* shared_preferences (for token storage)

---

## ARCHITECTURE

/lib
├── core/
├── data/
├── bloc/
├── presentation/

---

## RULES

* Always use Dio for API calls
* Always use BLoC for state management
* Store token in shared_preferences
* Use async/await
* Show loading and error states
* Do NOT use dummy data
* Keep code modular

---

## INITIAL FEATURES

* Splash Screen (check token)
* Login Screen
* Register Screen
* Product Listing Screen

---

## GOAL

Build a working frontend that:

* Authenticates user
* Fetches products from backend
* Displays product list
