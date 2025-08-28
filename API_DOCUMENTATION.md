# Shop API - Complete Testing Guide for Postman

Welcome to our comprehensive e-commerce API! This guide will walk you through testing the entire API functionality in a logical sequence that showcases all features. Each section includes complete Postman requests with expected responses.

## 🚀 Quick Setup

**Base URL**: `http://127.0.0.1:3000`
**API Version**: `v1`
**All API endpoints**: `http://127.0.0.1:3000/api/v1/`

## 📋 Testing Flow Overview

We'll test the API in this sequence to experience the full e-commerce journey:

1. **🌍 Public Routes** - Browse products without authentication
2. **🔐 Authentication Flow** - Sign up, confirm, and login
3. **👤 User Management** - Profile and user-specific data
4. **🛒 Shopping Cart** - Add, modify, and manage cart items
5. **❤️ Wishlist** - Save products for later
6. **📦 Order Management** - Complete purchase flow
7. **🔍 Advanced Features** - Categories, variants, and checkout

---

## 1️⃣ PUBLIC ROUTES - No Authentication Required

Start here to explore the catalog without creating an account.

### 1.1 Browse All Categories
See what product categories are available.

```http
GET http://127.0.0.1:3000/api/v1/categories
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "name": "Electronics",
    "description": "Electronic devices and gadgets",
    "created_at": "2025-08-28T08:00:00.000Z",
    "updated_at": "2025-08-28T08:00:00.000Z",
    "products": [
      {
        "id": 3,
        "name": "MacBook Pro",
        "price": 199999,
        "stock_quantity": 10,
        "in_stock": true
      }
    ]
  }
]
```

### 1.2 Browse All Products
View the complete product catalog with variants and category info.

```http
GET http://127.0.0.1:3000/api/v1/products
```

**Expected Response:**
```json
[
  {
    "id": 3,
    "name": "MacBook Pro",
    "price": 199999,
    "description": "Powerful laptop for professionals",
    "stock_quantity": 10,
    "sku": "LAPTOP-001",
    "in_stock": true,
    "category": {
      "id": 1,
      "name": "Electronics"
    },
    "product_variants": [
      {
        "id": 1,
        "name": "Storage",
        "value": "512GB",
        "price_modifier": 0,
        "stock_quantity": 5
      },
      {
        "id": 2,
        "name": "Storage",
        "value": "1TB",
        "price_modifier": 20000,
        "stock_quantity": 3
      }
    ]
  }
]
```

### 1.3 View Specific Product Details
Get detailed information about a single product.

```http
GET http://127.0.0.1:3000/api/v1/products/3
```

### 1.4 Browse Products by Category
Filter products by category.

```http
GET http://127.0.0.1:3000/api/v1/products?category_id=1
```

### 1.5 View In-Stock Products Only
See only available products.

```http
GET http://127.0.0.1:3000/api/v1/products?in_stock=true
```

---

## 2️⃣ AUTHENTICATION FLOW

Now let's create an account and get authenticated.

### 2.1 Sign Up New User
Create your account. **Note:** In development mode, accounts are auto-confirmed!

```http
POST http://127.0.0.1:3000/api/v1/signup
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "1234567890"
}
```

**Expected Response:**
```json
{
  "message": "Signup successful. Account auto-confirmed in development mode.",
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo2LCJleHAiOjE3MjQ5MDM0MDB9.token_here",
  "user": {
    "id": 6,
    "email": "john.doe@example.com",
    "full_name": "John Doe"
  }
}
```

**🎯 ACTION REQUIRED:** Copy the `token` value! You'll need it for all authenticated requests.

### 2.2 Login (Alternative Method)
If you need to login later or test login flow.

```http
POST http://127.0.0.1:3000/api/v1/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "password123"
}
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo2LCJleHAiOjE3MjQ5MDM0MDB9.token_here",
  "user": {
    "id": 6,
    "email": "john.doe@example.com",
    "full_name": "John Doe"
  }
}
```

---

## 3️⃣ USER MANAGEMENT - Authenticated Routes

**🔑 SETUP IN POSTMAN:**
- Go to Authorization tab
- Select "Bearer Token"
- Paste your token from step 2.1 or 2.2

### 3.1 View Your Profile
Get your complete user profile.

```http
GET http://127.0.0.1:3000/api/v1/users/profile
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
{
  "id": 6,
  "email": "john.doe@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "full_name": "John Doe",
  "phone": "1234567890",
  "shipping_address": null,
  "billing_address": null,
  "created_at": "2025-08-28T08:00:00.000Z",
  "updated_at": "2025-08-28T08:00:00.000Z"
}
```

### 3.2 Update Your Profile
Add shipping and billing addresses.

```http
PATCH http://127.0.0.1:3000/api/v1/users/6
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "9876543210",
  "shipping_address": "123 Main Street, New York, NY 10001",
  "billing_address": "123 Main Street, New York, NY 10001"
}
```

---

## 4️⃣ SHOPPING CART FLOW

Experience the complete cart management system.

### 4.1 Add First Product to Cart
Add MacBook Pro to your cart.

```http
POST http://127.0.0.1:3000/api/v1/carts/1/cart_items
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "product_id": 3,
  "quantity": 1
}
```

**Expected Response:**
```json
{
  "id": 1,
  "cart_id": 1,
  "product_id": 3,
  "quantity": 1,
  "total_price": 199999,
  "created_at": "2025-08-28T08:15:00.000Z",
  "updated_at": "2025-08-28T08:15:00.000Z",
  "product": {
    "id": 3,
    "name": "MacBook Pro",
    "price": 199999,
    "description": "Powerful laptop for professionals"
  }
}
```

### 4.2 Add Another Product
Add a t-shirt to your cart.

```http
POST http://127.0.0.1:3000/api/v1/carts/1/cart_items
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "product_id": 4,
  "quantity": 2
}
```

### 4.3 View Your Cart
See all items in your cart with totals.

```http
GET http://127.0.0.1:3000/api/v1/carts/1/cart_items
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "cart_id": 1,
    "product_id": 3,
    "quantity": 1,
    "total_price": 199999,
    "product": {
      "id": 3,
      "name": "MacBook Pro",
      "price": 199999
    }
  },
  {
    "id": 2,
    "cart_id": 1,
    "product_id": 4,
    "quantity": 2,
    "total_price": 3998,
    "product": {
      "id": 4,
      "name": "Cotton T-Shirt",
      "price": 1999
    }
  }
]
```

### 4.4 Update Cart Item Quantity
Change the t-shirt quantity from 2 to 3.

```http
PATCH http://127.0.0.1:3000/api/v1/carts/1/cart_items/2
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "quantity": 3
}
```

### 4.5 Remove Item from Cart
Remove the t-shirt completely.

```http
DELETE http://127.0.0.1:3000/api/v1/carts/1/cart_items/2
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:** `204 No Content`

---

## 5️⃣ WISHLIST FUNCTIONALITY

Save products for later purchase.

### 5.1 Add Product to Wishlist
Save the MacBook Pro for later.

```http
POST http://127.0.0.1:3000/api/v1/products/3/toggle_wishlist
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
{
  "message": "Product added to wishlist",
  "wishlisted": true
}
```

### 5.2 View Your Wishlist
See all your saved products.

```http
GET http://127.0.0.1:3000/api/v1/users/6/wishlist
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "user_id": 6,
    "product_id": 3,
    "created_at": "2025-08-28T08:20:00.000Z",
    "product": {
      "id": 3,
      "name": "MacBook Pro",
      "price": 199999,
      "description": "Powerful laptop for professionals"
    }
  }
]
```

### 5.3 Remove from Wishlist
Toggle the same product to remove it.

```http
POST http://127.0.0.1:3000/api/v1/products/3/toggle_wishlist
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
{
  "message": "Product removed from wishlist",
  "wishlisted": false
}
```

---

## 6️⃣ ORDER MANAGEMENT - Complete Purchase Flow

Experience the full ordering system from cart to delivery.

### 6.1 Prepare Cart for Order
First, make sure you have items in your cart (repeat step 4.1 if needed).

```http
POST http://127.0.0.1:3000/api/v1/carts/1/cart_items
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "product_id": 3,
  "quantity": 1
}
```

### 6.2 Create Order from Cart
Convert your cart items to an order. **Note:** This will empty your cart!

```http
POST http://127.0.0.1:3000/api/v1/orders
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "shipping_address": "123 Main Street, New York, NY 10001",
  "billing_address": "123 Main Street, New York, NY 10001"
}
```

**Expected Response:**
```json
{
  "id": 1,
  "user_id": 6,
  "order_number": "ORD-000001",
  "status": "pending",
  "total_amount": 199999,
  "shipping_address": "123 Main Street, New York, NY 10001",
  "billing_address": "123 Main Street, New York, NY 10001",
  "created_at": "2025-08-28T08:30:00.000Z",
  "updated_at": "2025-08-28T08:30:00.000Z",
  "order_items": [
    {
      "id": 1,
      "order_id": 1,
      "product_id": 3,
      "quantity": 1,
      "price": 199999,
      "total_price": 199999,
      "product": {
        "id": 3,
        "name": "MacBook Pro",
        "price": 199999
      }
    }
  ]
}
```

### 6.3 Verify Cart is Empty
Check that your cart was cleared after order creation.

```http
GET http://127.0.0.1:3000/api/v1/carts/1/cart_items
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:** `[]` (empty array)

### 6.4 View Your Orders
See your complete order history.

```http
GET http://127.0.0.1:3000/api/v1/orders
Authorization: Bearer YOUR_TOKEN_HERE
```

### 6.5 View Specific Order Details
Get detailed information about your order.

```http
GET http://127.0.0.1:3000/api/v1/orders/1
Authorization: Bearer YOUR_TOKEN_HERE
```

### 6.6 Cancel Order (If Allowed)
Cancel your order while it's still pending.

```http
PATCH http://127.0.0.1:3000/api/v1/orders/1/cancel
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
{
  "message": "Order cancelled successfully"
}
```

---

## 7️⃣ CHECKOUT FLOW

Test the secure checkout session system.

### 7.1 Add Items to Cart (for Checkout)
Prepare cart for checkout testing.

```http
POST http://127.0.0.1:3000/api/v1/carts/1/cart_items
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "product_id": 4,
  "quantity": 2
}
```

### 7.2 Create Checkout Session
Initialize secure checkout process.

```http
POST http://127.0.0.1:3000/api/v1/checkout
Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
{
  "checkout_session": {
    "id": "uuid-session-id-here",
    "user_id": 6,
    "items": [
      {
        "product_id": 4,
        "product_name": "Cotton T-Shirt",
        "quantity": 2,
        "price": 1999,
        "total": 3998
      }
    ],
    "total_amount": 3998,
    "created_at": "2025-08-28T08:40:00.000Z",
    "expires_at": "2025-08-28T08:55:00.000Z"
  },
  "message": "Checkout session created. Complete payment within 15 minutes."
}
```

### 7.3 Retrieve Checkout Session
Check your checkout session status.

```http
GET http://127.0.0.1:3000/api/v1/checkout/session/YOUR_SESSION_ID_HERE
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 🎯 COMPLETE API TESTING CHECKLIST

Use this checklist to verify you've tested all functionality:

### Public Routes ✅
- [ ] Browse categories
- [ ] View all products
- [ ] View single product
- [ ] Filter products by category
- [ ] Filter in-stock products

### Authentication ✅
- [ ] Sign up new user
- [ ] Login existing user
- [ ] Get JWT token

### User Management ✅
- [ ] View profile
- [ ] Update profile information

### Shopping Cart ✅
- [ ] Add products to cart
- [ ] View cart items
- [ ] Update item quantities
- [ ] Remove items from cart

### Wishlist ✅
- [ ] Add products to wishlist
- [ ] View wishlist
- [ ] Remove from wishlist

### Orders ✅
- [ ] Create order from cart
- [ ] Verify cart emptied after order
- [ ] View order history
- [ ] View order details
- [ ] Cancel pending order

### Checkout ✅
- [ ] Create checkout session
- [ ] Retrieve checkout session

---

## 🚨 Important Notes

1. **Authentication**: Always include the Bearer token for protected routes
2. **Stock Management**: Products have limited stock - ordering reduces inventory
3. **Cart Behavior**: Creating an order empties your cart automatically
4. **Order Status**: Orders start as "pending" and can be cancelled
5. **Checkout Sessions**: Expire after 15 minutes for security
6. **Price Format**: All prices are in cents (199999 = $1,999.99)

---

## 🎉 Congratulations!

You've now tested the complete e-commerce API functionality! This API provides:

- ✅ **Product Catalog** with categories and variants
- ✅ **User Authentication** with JWT tokens  
- ✅ **Shopping Cart** management
- ✅ **Wishlist** functionality
- ✅ **Complete Order Flow** from cart to delivery
- ✅ **Secure Checkout** with session management
- ✅ **Stock Management** and inventory tracking
- ✅ **User Profile** management

The API is production-ready and can power any e-commerce frontend application!
