# 🛒 Shop API - E-commerce Backend

A comprehensive RESTful API for e-commerce applications built with Ruby on Rails. This API provides complete functionality for managing products, user authentication, shopping carts, wishlists, order processing, and secure checkout flows.

## ✨ Features

🔐 **JWT Authentication** - Secure user authentication with email confirmation  
📦 **Product Management** - CRUD operations with categories and variants  
🛒 **Shopping Cart** - Full cart management with automatic total calculations  
❤️ **Wishlist** - Save products for later purchase  
📋 **Order Management** - Complete order lifecycle with status tracking  
💳 **Checkout System** - Secure checkout sessions with expiration  
🏷️ **Product Categories** - Organize products with category relationships  
🎨 **Product Variants** - Support for different product variations (size, color, storage, etc.)  
📊 **Stock Management** - Real-time inventory tracking and low stock prevention  
📱 **API Versioning** - Future-proof API design with versioned endpoints  
🌐 **CORS Support** - Ready for frontend integration  

## 🛠️ Tech Stack

- **Framework**: Ruby on Rails 8.0.2.1 (API-only mode)
- **Database**: SQLite 3 (Development) / PostgreSQL (Production-ready)
- **Authentication**: JWT with bcrypt password encryption
- **Email**: ActionMailer with MailCatcher (development)
- **CORS**: rack-cors for cross-origin requests
- **Testing**: Built-in Rails testing framework

---

## 🚀 Quick Start Guide

Follow these steps to get the API running on your local machine after cloning from GitHub.

### Prerequisites

Make sure you have the following installed:
- **Ruby 3.3.6** (use `ruby -v` to check)
- **Rails 8.0.2.1** (use `rails -v` to check)
- **SQLite3** (for development database)
- **Git** (for cloning the repository)

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/CCumari/newshop-api.git
cd newshop-api/shop
```

### 2️⃣ Install Dependencies

```bash
# Install Ruby gems
bundle install

# If you encounter any gem conflicts, try:
bundle update
```

### 3️⃣ Database Setup

```bash
# Create the database
rails db:create

# Run all migrations to set up tables
rails db:migrate

# Seed the database with sample data (optional but recommended)
rails db:seed
```

**What gets seeded:**
- 3 product categories (Electronics, Clothing, Books)
- 6 sample products with descriptions and stock
- 13+ product variants (different sizes, colors, storage options)
- All relationships properly configured

### 4️⃣ Start the Server

```bash
# Start the Rails server
rails server

# Or use the shorter version:
rails s
```

The API will be available at: **http://127.0.0.1:3000**

### 5️⃣ Email Setup (Optional)

For testing email confirmations and notifications:

```bash
# Install MailCatcher gem globally
gem install mailcatcher

# Start MailCatcher (in a separate terminal)
mailcatcher

# Access MailCatcher web interface at:
# http://127.0.0.1:1080
```

### 6️⃣ Test the API

**Quick Health Check:**
```bash
curl http://127.0.0.1:3000/api/v1/products
```

**Or visit in your browser:**
- Products: http://127.0.0.1:3000/api/v1/products
- Categories: http://127.0.0.1:3000/api/v1/categories

### 7️⃣ API Documentation & Testing

📖 **Complete API Documentation**: Check `API_DOCUMENTATION.md` for detailed endpoint information and Postman testing guide.

The documentation includes:
- Step-by-step testing flows
- Complete request/response examples
- Authentication setup instructions
- Sample JSON payloads for all endpoints

---

## 🗂️ Project Structure

```
shop/
├── app/
│   ├── controllers/
│   │   ├── api/v1/          # Versioned API controllers
│   │   └── concerns/        # Shared controller logic
│   ├── models/              # Data models with validations
│   ├── mailers/             # Email templates and logic
│   └── jobs/                # Background job processing
├── config/
│   ├── routes.rb            # API endpoint definitions
│   ├── database.yml         # Database configuration
│   └── initializers/        # App initialization settings
├── db/
│   ├── migrate/             # Database migration files
│   ├── seeds.rb             # Sample data for development
│   └── schema.rb            # Current database structure
├── API_DOCUMENTATION.md     # Complete API testing guide
└── README.md               # This file
```

---

## 🔧 Configuration

### Environment Variables

Create a `.env` file (optional) for customization:

```bash
# Database
DATABASE_URL=sqlite3:storage/development.sqlite3

# JWT Secret (auto-generated in Rails credentials)
# JWT_SECRET=your-secret-key

# Email (for production)
# SMTP_USERNAME=your-email
# SMTP_PASSWORD=your-password

# CORS Origins (customize for your frontend)
# CORS_ORIGINS=http://localhost:3000,http://localhost:3001
```

### Database Configuration

**Development**: Uses SQLite3 (no setup required)
**Production**: Easily switchable to PostgreSQL or MySQL

### CORS Configuration

CORS is pre-configured for development. For production, update `config/initializers/cors.rb` with your frontend domains.

---

## 🧪 Testing

```bash
# Run all tests
rails test

# Run specific test files
rails test test/controllers/
rails test test/models/

# Run tests with coverage
COVERAGE=true rails test
```

---

## 📊 API Endpoints Overview

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/v1/products` | Browse products | ❌ |
| GET | `/api/v1/categories` | Browse categories | ❌ |
| POST | `/api/v1/signup` | Create account | ❌ |
| POST | `/api/v1/login` | User login | ❌ |
| GET | `/api/v1/users/profile` | User profile | ✅ |
| POST | `/api/v1/carts/:id/cart_items` | Add to cart | ✅ |
| POST | `/api/v1/orders` | Create order | ✅ |
| POST | `/api/v1/checkout` | Checkout session | ✅ |

**Full endpoint documentation**: See `API_DOCUMENTATION.md`

---

## 🚀 Deployment

### Heroku Deployment

```bash
# Create Heroku app
heroku create your-shop-api

# Set production database
heroku addons:create heroku-postgresql:mini

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Seed production data (optional)
heroku run rails db:seed
```

### Docker Deployment

```bash
# Build Docker image
docker build -t shop-api .

# Run container
docker run -p 3000:3000 shop-api
```

---

## 🎯 Suggestions for Improvement

### 🔥 High Priority Features

#### **Payment Integration**
- **Stripe Integration**: Add credit card processing
- **PayPal Support**: Alternative payment method
- **Payment Webhooks**: Handle payment confirmations
- **Refund System**: Process returns and refunds

#### **Advanced Product Features**
- **Product Images**: File upload with cloud storage (AWS S3/Cloudinary)
- **Product Reviews**: 5-star rating system with comments
- **Product Search**: Full-text search with filters (brand, price range, rating)
- **Related Products**: "You might also like" recommendations
- **Product Bundles**: Group products with discounts

#### **Enhanced User Experience**
- **Social Login**: Google, Facebook, Apple OAuth
- **Two-Factor Authentication**: SMS/Email 2FA for security
- **Password Reset**: Secure password recovery flow
- **Account Verification**: Phone number verification

### 🛒 E-commerce Enhancements

#### **Advanced Shopping Features**
- **Guest Checkout**: Purchase without creating account
- **Save for Later**: Move cart items to wishlist
- **Recently Viewed**: Track user browsing history
- **Price Alerts**: Notify when wishlisted items go on sale
- **Quick Reorder**: One-click reorder from order history

#### **Inventory & Stock Management**
- **Low Stock Alerts**: Admin notifications
- **Backorder Support**: Allow orders when out of stock
- **Stock Reservations**: Hold inventory during checkout
- **Bulk Inventory Updates**: CSV import/export

#### **Order Management**
- **Order Tracking**: Real-time shipping updates
- **Order Modifications**: Allow changes before processing
- **Partial Fulfillment**: Ship items as they become available
- **Return Management**: RMA system with return labels

### 💰 Business Features

#### **Marketing & Sales**
- **Discount Codes**: Percentage and fixed amount coupons
- **Flash Sales**: Time-limited promotions
- **Loyalty Program**: Points system for repeat customers
- **Referral System**: Reward users for bringing friends
- **Abandoned Cart Recovery**: Email reminders

#### **Analytics & Reporting**
- **Sales Dashboard**: Revenue, orders, popular products
- **User Analytics**: Registration, conversion, retention rates
- **Product Performance**: Best sellers, slow movers
- **A/B Testing**: Test different prices, descriptions
- **Export Reports**: CSV/Excel downloads for business intelligence

#### **Admin & Management**
- **Admin Dashboard**: Web interface for managing products, orders, users
- **Bulk Operations**: Mass update products, process orders
- **User Management**: Admin roles, permissions, customer support tools
- **Content Management**: Homepage banners, featured products
- **Settings Panel**: Configure taxes, shipping, email templates

### 🔧 Technical Improvements

#### **Performance & Scalability**
- **Redis Caching**: Cache frequently accessed data
- **Database Optimization**: Add indexes, optimize queries
- **Background Jobs**: Process emails, reports async with Sidekiq
- **CDN Integration**: Serve static assets via CloudFront
- **Database Sharding**: Scale for millions of products

#### **Security Enhancements**
- **Rate Limiting**: Prevent API abuse
- **Input Validation**: Stronger sanitization
- **Audit Logging**: Track all admin actions
- **GDPR Compliance**: Data export, deletion rights
- **PCI Compliance**: Secure payment data handling

#### **Developer Experience**
- **API Versioning**: v2, v3 with backward compatibility
- **GraphQL Support**: Alternative to REST API
- **Swagger Documentation**: Interactive API explorer
- **SDK Development**: Official libraries for popular languages
- **Webhook System**: Notify external systems of events

### 📱 Platform Extensions

#### **Mobile & Integration**
- **Mobile App API**: Optimized endpoints for iOS/Android
- **Progressive Web App**: PWA-ready API responses
- **Social Media**: Instagram Shopping, Facebook Marketplace
- **Marketplace Integration**: Amazon, eBay, Etsy sync
- **ERP Integration**: Connect with business management systems

#### **Advanced Features**
- **AI Recommendations**: Machine learning product suggestions
- **Chatbot Integration**: Customer service automation
- **Multi-language**: Internationalization support
- **Multi-currency**: Dynamic currency conversion
- **Subscription Products**: Recurring billing for consumables

---

## 📈 Roadmap Prioritization

### **Phase 1** (Next 2-4 weeks)
1. Payment integration (Stripe)
2. Product image uploads
3. Admin dashboard basics
4. Email notifications

### **Phase 2** (1-2 months)
1. Product reviews and ratings
2. Advanced search and filters
3. Discount/coupon system
4. Order tracking

### **Phase 3** (2-3 months)
1. Mobile app API optimization
2. Analytics dashboard
3. Inventory management
4. Multi-language support

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 Support

- **Documentation**: `API_DOCUMENTATION.md`
- **Issues**: GitHub Issues page
- **Email**: [your-email@domain.com]

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🎉 Acknowledgments

- Built with Ruby on Rails framework
- Inspired by modern e-commerce best practices
- Thanks to the open-source community for excellent gems and tools

---

**Happy coding! 🚀**
