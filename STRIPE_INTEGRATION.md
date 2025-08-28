# Stripe Payment Integration - Complete Guide

## 🎯 Overview

We've successfully integrated a comprehensive payment system into your Shop API with:

- ✅ **Stripe Payment Processing** - Credit card payments with 3D Secure support
- ✅ **Payment Intents API** - Modern, secure payment flow
- ✅ **Webhook System** - Real-time payment status updates
- ✅ **Refund Management** - Full and partial refunds
- ✅ **Customer Management** - Stripe customer creation and management
- ✅ **Payment Tracking** - Complete audit trail of all transactions

---

## 🔧 Setup Instructions

### 1️⃣ Get Stripe API Keys

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys)
2. Copy your **Publishable Key** and **Secret Key**
3. For webhooks, you'll need the **Endpoint Secret**

### 2️⃣ Configure Environment Variables

Create a `.env` file in your project root:

```bash
# Test keys (for development)
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_ENDPOINT_SECRET=whsec_your_endpoint_secret_here
```

### 3️⃣ Update Stripe Configuration

Edit `config/initializers/stripe.rb` with your actual keys:

```ruby
Rails.application.configure do
  config.stripe = {
    publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
    secret_key: ENV['STRIPE_SECRET_KEY'],
    endpoint_secret: ENV['STRIPE_ENDPOINT_SECRET']
  }
end

Stripe.api_key = Rails.application.config.stripe[:secret_key]
```

---

## 🧪 Complete Postman Testing Workflow

### � **Prerequisites**
1. **Rails Server Running**: `rails server` (Port 3000)
2. **JWT Token**: From login/signup response
3. **Postman Installed**: With proper headers configured

---

## 🚀 **Method 1: Testing-Only Flow (No Stripe Dashboard)**

### **Step 1: Setup Postman Environment**
Create these environment variables in Postman:
- `base_url` = `http://127.0.0.1:3000`
- `jwt_token` = Your JWT token from login
- `order_id` = Will be set dynamically
- `payment_id` = Will be set dynamically

### **Step 2: Add Items to Cart**
```http
POST {{base_url}}/api/v1/carts/1/cart_items
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "product_id": 3,
  "quantity": 1
}
```

**✅ Success Response:**
```json
{
  "id": 1,
  "cart_id": 1,
  "product_id": 3,
  "quantity": 1,
  "total_price": 199999
}
```

### **Step 3: Create Checkout Session**
```http
POST {{base_url}}/api/v1/checkout
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "shipping_address": "123 Main St, New York, NY 10001",
  "billing_address": "123 Main St, New York, NY 10001"
}
```

**✅ Success Response:**
```json
{
  "checkout_session": {
    "order_id": 8,
    "order_number": "ORD-000008",
    "status": "payment_pending"
  },
  "payment_intent": {
    "id": "pi_3S10xxx",
    "status": "requires_payment_method"
  }
}
```

**📝 In Postman Tests Tab, add this script:**
```javascript
// Save order_id for next requests
if (pm.response.json().checkout_session) {
    pm.environment.set("order_id", pm.response.json().checkout_session.order_id);
}
```

### **Step 4: Get Payment Details**
```http
GET {{base_url}}/api/v1/orders/{{order_id}}/payments
Authorization: Bearer {{jwt_token}}
```

**✅ Success Response:**
```json
[
  {
    "id": 1,
    "amount": "199999.0",
    "status": "pending",
    "refundable_amount": "0.0"
  }
]
```

**📝 In Postman Tests Tab, add:**
```javascript
// Save payment_id for next requests
if (pm.response.json().length > 0) {
    pm.environment.set("payment_id", pm.response.json()[0].id);
}
```

### **Step 5: Accept Payment (Testing Method)**
```http
POST {{base_url}}/api/v1/orders/{{order_id}}/payments/{{payment_id}}/accept
Authorization: Bearer {{jwt_token}}
```

**✅ Success Response:**
```json
{
  "message": "Payment accepted successfully",
  "payment": {
    "id": 1,
    "status": "succeeded"
  },
  "order": {
    "id": 8,
    "status": "confirmed"
  },
  "note": "This simulates a successful payment for testing purposes"
}
```

**⚠️ Note:** This will **NOT** appear in Stripe Dashboard - it's purely for API testing.

### **Step 6: Verify Order Status**
```http
GET {{base_url}}/api/v1/orders/{{order_id}}
Authorization: Bearer {{jwt_token}}
```

**✅ Expected Changes:**
- Order status: `confirmed`
- Payment status: `succeeded`
- Cart: Empty (cleared automatically)

---

## 💳 **Method 2: Real Stripe Integration Flow**

### **Step 1-4: Same as Method 1**
Follow steps 1-4 from Method 1 above.

### **Step 5A: Start Stripe Webhook Listener**
```bash
stripe listen --forward-to http://127.0.0.1:3000/api/v1/webhooks/stripe
```

### **Step 5B: Confirm Payment via Stripe CLI**
```bash
stripe payment_intents confirm pi_YOUR_PAYMENT_INTENT_ID --payment-method pm_card_visa
```

**✅ This WILL appear in:**
- ✅ Stripe Dashboard
- ✅ Stripe CLI output
- ✅ Your Rails server logs
- ✅ Webhook events

### **Step 6: Verify Real Integration**
Same as Method 1 Step 6, but now the payment was processed through actual Stripe.

---

## 💰 **Refund Testing Workflow**

### **Step 1: Create Full Refund**
```http
POST {{base_url}}/api/v1/orders/{{order_id}}/payments/{{payment_id}}/refunds
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "reason": "Customer requested full refund"
}
```

### **Step 2: Create Partial Refund**
```http
POST {{base_url}}/api/v1/orders/{{order_id}}/payments/{{payment_id}}/refunds
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "amount": 50.00,
  "reason": "Partial refund for damaged item"
}
```

### **Step 3: Get All Refunds**
```http
GET {{base_url}}/api/v1/orders/{{order_id}}/refunds
Authorization: Bearer {{jwt_token}}
```

### **Step 4: Get Specific Refund**
```http
GET {{base_url}}/api/v1/orders/{{order_id}}/refunds/1
Authorization: Bearer {{jwt_token}}
```

---

## 🔄 **Error Testing Workflow**

### **Test 1: Empty Cart Checkout**
```http
POST {{base_url}}/api/v1/checkout
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "shipping_address": "123 Main St",
  "billing_address": "123 Main St"
}
```
**Expected:** `422 Unprocessable Entity` - "Cart is empty"

### **Test 2: Insufficient Stock**
```http
POST {{base_url}}/api/v1/carts/1/cart_items
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "product_id": 3,
  "quantity": 999999
}
```
**Expected:** `422 Unprocessable Entity` - Stock validation error

### **Test 3: Invalid Refund Amount**
```http
POST {{base_url}}/api/v1/orders/{{order_id}}/payments/{{payment_id}}/refunds
Authorization: Bearer {{jwt_token}}
Content-Type: application/json

{
  "amount": 999999.00,
  "reason": "Testing over-refund"
}
```
**Expected:** `422 Unprocessable Entity` - Amount validation error

---

## 📊 **Complete Testing Collection for Postman**

### **Collection Structure:**
```
📁 Shop API - Payment Testing
├── 📁 1. Setup & Authentication
│   ├── POST Login/Signup
│   └── GET User Profile
├── 📁 2. Cart Management  
│   ├── POST Add to Cart
│   ├── GET Cart Items
│   └── DELETE Cart Item
├── 📁 3. Checkout & Orders
│   ├── POST Create Checkout
│   ├── GET Order Details
│   └── GET Order List
├── 📁 4. Payment Processing
│   ├── GET Order Payments
│   ├── POST Accept Payment (Testing)
│   ├── POST Confirm Payment (Real Stripe)
│   └── POST Cancel Payment
├── 📁 5. Refund Management
│   ├── POST Full Refund
│   ├── POST Partial Refund
│   ├── GET Refunds List
│   └── POST Cancel Refund
└── 📁 6. Error Testing
    ├── POST Empty Cart Checkout
    ├── POST Invalid Stock
    └── POST Invalid Refund
```

---

## 🎯 **Key Differences Summary**

| Method | Stripe Dashboard | Stripe CLI | Webhooks | Use Case |
|--------|------------------|------------|----------|----------|
| **Testing Accept Route** | ❌ No | ❌ No | ❌ No | API testing only |
| **Real Stripe Flow** | ✅ Yes | ✅ Yes | ✅ Yes | Production-ready |

---

## 🔧 **Postman Environment Setup**

Create a new environment with these variables:
```json
{
  "base_url": "http://127.0.0.1:3000",
  "jwt_token": "YOUR_JWT_TOKEN_HERE",
  "order_id": "",
  "payment_id": "",
  "refund_id": ""
}
```

---

## 🚨 **Important Notes**

1. **Testing Accept Route**: Only updates your database, perfect for API development
2. **Real Stripe Flow**: Processes actual payments, use for integration testing
3. **Environment Variables**: Use Postman environments to avoid hardcoding IDs
4. **Error Handling**: Test both success and failure scenarios
5. **Webhook Testing**: Requires Stripe CLI for real webhook events

This workflow gives you complete coverage of all payment functionality! 🎉

---

## 🔗 Webhook Configuration

### Setting up Webhooks

1. **Stripe CLI (Development):**
   ```bash
   stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
   ```

2. **Stripe Dashboard (Production):**
   - Go to Webhooks section
   - Add endpoint: `https://yourdomain.com/api/v1/webhooks/stripe`
   - Select events: `payment_intent.*`, `refund.*`

### Handled Webhook Events

- `payment_intent.succeeded` - Payment completed successfully
- `payment_intent.payment_failed` - Payment failed
- `payment_intent.canceled` - Payment was cancelled
- `payment_intent.requires_action` - 3D Secure authentication needed
- `charge.dispute.created` - Chargeback/dispute created
- `refund.created` - Refund initiated
- `refund.updated` - Refund status changed

---

## 💳 Frontend Integration Example

### JavaScript/React Example

```javascript
// 1. Create checkout session
const checkoutResponse = await fetch('/api/v1/checkout', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    shipping_address: "123 Main St, City, State 12345",
    billing_address: "123 Main St, City, State 12345"
  })
});

const { payment_intent } = await checkoutResponse.json();

// 2. Initialize Stripe
const stripe = Stripe('pk_test_your_publishable_key_here');

// 3. Confirm payment
const { error, paymentIntent } = await stripe.confirmCardPayment(
  payment_intent.client_secret,
  {
    payment_method: {
      card: cardElement,
      billing_details: {
        name: 'Customer Name',
        email: 'customer@example.com'
      }
    }
  }
);

if (error) {
  console.error('Payment failed:', error);
} else if (paymentIntent.status === 'succeeded') {
  console.log('Payment succeeded!');
}
```

---

## 📊 Database Schema

### Payments Table
```sql
CREATE TABLE payments (
  id BIGINT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  stripe_payment_intent_id VARCHAR,
  amount DECIMAL(10,2),
  status VARCHAR,
  payment_method VARCHAR,
  stripe_customer_id VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Refunds Table
```sql
CREATE TABLE refunds (
  id BIGINT PRIMARY KEY,
  payment_id BIGINT NOT NULL,
  order_id BIGINT NOT NULL,
  amount DECIMAL(10,2),
  status VARCHAR,
  stripe_refund_id VARCHAR,
  reason TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

---

## 🔒 Security Features

### ✅ Implemented Security Measures

1. **Webhook Signature Verification** - Validates Stripe webhooks
2. **Payment Intent Idempotency** - Prevents duplicate charges
3. **Amount Validation** - Prevents overpayment and invalid amounts
4. **User Authorization** - Only order owners can manage payments
5. **Refund Limits** - Cannot refund more than paid amount
6. **Status Validation** - Prevents invalid state transitions

### 🔐 Additional Recommendations

```ruby
# In production, add these security headers
# config/application.rb
config.force_ssl = true
config.ssl_options = { redirect: { exclude: ->(request) { request.path.start_with?('/api/v1/webhooks/') } } }
```

---

## 🧪 Testing Guide

### Test Payment Flow

1. **Setup Test Data**
   ```bash
   rails db:seed  # Creates test products and categories
   ```

2. **Test Credit Cards** (Stripe Test Mode)
   - Success: `4242424242424242`
   - Decline: `4000000000000002`
   - 3D Secure: `4000000000003220`

3. **Test Webhooks**
   ```bash
   stripe trigger payment_intent.succeeded
   ```

### Manual Testing Sequence

1. Create user account → Get JWT token
2. Add products to cart
3. Create checkout session
4. Use Stripe test card to complete payment
5. Verify webhook updates order status
6. Test partial refund
7. Test full refund

---

## 📈 Monitoring & Analytics

### Key Metrics to Track

```ruby
# In Rails console or analytics dashboard
successful_payments = Payment.successful.count
failed_payments = Payment.failed.count
total_revenue = Payment.successful.sum(:amount)
refund_rate = (Refund.successful.sum(:amount) / total_revenue * 100).round(2)
```

### Logging

Check these log files for payment activity:
- `log/development.log` - General application logs
- Stripe Dashboard - Payment and webhook logs
- Your monitoring service (recommended: Sentry, Bugsnag)

---

## 🚨 Error Handling

### Common Payment Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `card_declined` | Insufficient funds | Ask customer to use different card |
| `authentication_required` | 3D Secure needed | Handle `requires_action` status |
| `invalid_payment_method` | Invalid card details | Validate card input |
| `amount_too_small` | Below minimum amount | Check Stripe minimums by currency |

### Refund Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `charge_already_refunded` | Already fully refunded | Check refundable amount |
| `amount_too_large` | Refund > paid amount | Validate refund amount |

---

## 🔄 Order Status Flow

```
pending → payment_pending → confirmed → processing → shipped → delivered
   ↓              ↓             ↓
cancelled     cancelled    refunded
```

**Status Descriptions:**
- `pending` - Order created, no payment initiated
- `payment_pending` - Payment intent created, awaiting payment
- `confirmed` - Payment successful, order confirmed
- `processing` - Order being prepared
- `shipped` - Order dispatched
- `delivered` - Order delivered
- `cancelled` - Order cancelled (with/without payment)
- `refunded` - Order fully refunded

---

## 🎉 Success! 

Your Shop API now has enterprise-grade payment processing capabilities:

- **Secure Payment Processing** with Stripe
- **Real-time Webhooks** for payment updates
- **Complete Refund System** with audit trails
- **Customer Management** for repeat purchases
- **Comprehensive API** for frontend integration

The system is production-ready and follows payment industry best practices!

---

## 🆘 Support

- **Stripe Documentation**: https://stripe.com/docs
- **Webhook Testing**: Use Stripe CLI for local development
- **Error Logs**: Check Rails logs and Stripe Dashboard
- **API Status**: https://status.stripe.com
