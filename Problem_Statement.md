# Business Problem Statement

## Project: Improving Marketplace Performance Through Seller, Delivery, and Customer Behavior Analytics

**Dataset:** Olist Brazilian E-Commerce Public Dataset (orders, order items, sellers, customers, payments, reviews, products, geolocation)

---

## Context

Olist is an online marketplace connecting small Brazilian retailers (sellers) to major
e-commerce platforms. Every order flows through seller → logistics → customer, followed
by a post-delivery review. Marketplace leadership needs visibility across the full order
lifecycle and not just "which sellers are bad," but how seller behavior, delivery
efficiency, product category, payment method, and region interact to drive (or hurt)
overall marketplace performance.

## Problem Statement

Olist's leadership lacks a unified view of marketplace performance. Seller quality,
delivery delays, customer satisfaction, and regional differences are currently
understood in isolation, making it hard to answer basic operational
questions: which sellers and regions drive the business, where delays actually come
from, whether delays are costing customer satisfaction, and which product categories
carry disproportionate logistics cost relative to the revenue they generate.

## Objective

Build an end-to-end analysis (SQL → Python → Power BI) that gives the analytics team a
single source of truth on marketplace health, and produce a business report with
concrete, data-backed recommendations.

## Research Questions

**Operational Performance**
1. Which sellers contribute the most revenue?
2. Which sellers have the highest late-delivery rates?

**Customer Experience**
3. Does delivery delay measurably reduce review scores?
4. Which product categories receive the most complaints / lowest review scores?

**Revenue & Cost Insights**
5. Which product categories generate high revenue but high freight/logistics cost
   relative to that revenue? *(Note: the dataset has no seller-side cost data, so this
   is a revenue-vs-logistics-cost efficiency question, not a true profit margin
   question.)*
6. Which payment methods are most commonly used, and does payment type/installment
   count correlate with order value or delay?

**Regional Insights**
7. Which states generate the most revenue?
8. Which regions experience the most delivery delays?

**Seller Risk Analysis**
9. Which high-volume sellers consistently receive poor reviews — i.e., high-impact
   underperformers, not just small bad actors?

## Success Metric / Deliverable

- A Power BI dashboard covering seller, delivery, customer, revenue, and regional views
- A written business report translating findings into recommendations (which sellers to
  audit/support, which regions/categories need logistics attention)

## Pipeline

Define Business Problem → Explore raw tables in SQL → Merge & clean into an aggregated
table → Load into Python (Jupyter) → EDA answering the research questions above →
Power BI dashboard → Business report
