# Database Schema Documentation


This document provides a detailed breakdown of the **md\_water\_services** database schema, including table structures, column descriptions, and data types.

---

## Employee Table

Stores details of field employees responsible for water monitoring and data collection.

| Column Name            | Description                          | Data Type    |
| ---------------------- | ------------------------------------ | ------------ |
| assigned\_employee\_id | Unique identifier for each employee  | INT          |
| employee\_name         | Full name of the employee            | VARCHAR(255) |
| phone\_number          | Contact number                       | VARCHAR(15)  |
| email                  | Email address                        | VARCHAR(255) |
| address                | Residential address                  | VARCHAR(255) |
| town\_name             | Town where the employee is based     | VARCHAR(255) |
| province\_name         | Province where the employee is based | VARCHAR(255) |
| position               | Job title                            | VARCHAR(255) |

---

## Global Water Access Table

Provides a high-level overview of water access statistics by country and region.

| Column Name   | Description                                              | Data Type    |
| ------------- | -------------------------------------------------------- | ------------ |
| name          | Country/region name                                      | VARCHAR(255) |
| region        | Geographical region                                      | VARCHAR(255) |
| year          | Year of data collection                                  | INT          |
| pop\_n        | National population estimate (in thousands)              | FLOAT        |
| pop\_u        | Urban population share (%)                               | FLOAT        |
| wat\_bas\_n   | % of population with basic water service (national)      | FLOAT        |
| wat\_lim\_n   | % of population with limited water service (national)    | FLOAT        |
| wat\_unimp\_n | % of population with unimproved water service (national) | FLOAT        |
| wat\_sur\_n   | % of population relying on surface water (national)      | FLOAT        |
| wat\_bas\_r   | % of rural population with basic water service           | FLOAT        |
| wat\_lim\_r   | % of rural population with limited water service         | FLOAT        |
| wat\_unimp\_r | % of rural population with unimproved water service      | FLOAT        |
| wat\_sur\_r   | % of rural population relying on surface water           | FLOAT        |
| wat\_bas\_u   | % of urban population with basic water service           | FLOAT        |
| wat\_lim\_u   | % of urban population with limited water service         | FLOAT        |
| wat\_unimp\_u | % of urban population with unimproved water service      | FLOAT        |
| wat\_sur\_u   | % of urban population relying on surface water           | FLOAT        |

---

## Location Table

Captures surveyed locations, categorized by geographical data and type of water service point.

| Column Name    | Description                                       | Data Type    |
| -------------- | ------------------------------------------------- | ------------ |
| location\_id   | Unique ID for each location                       | VARCHAR(255) |
| address        | Physical address                                  | VARCHAR(255) |
| province\_name | Province of the location                          | VARCHAR(255) |
| town\_name     | Town where the location is situated               | VARCHAR(255) |
| location\_type | Category of the location (e.g., well, tap, river) | VARCHAR(255) |

---

## Visits Table

Records field visits to water sources, tracking the frequency, conditions, and wait times at each location.

| Column Name            | Description                                 | Data Type    |
| ---------------------- | ------------------------------------------- | ------------ |
| record\_id             | Unique visit ID                             | INT          |
| location\_id           | ID of the visited location                  | VARCHAR(255) |
| source\_id             | ID of the water source                      | VARCHAR(510) |
| time\_of\_record       | Date and time of the visit                  | DATETIME     |
| visit\_count           | Number of visits recorded for this location | INT          |
| time\_in\_queue        | Average wait time for water (minutes)       | INT          |
| assigned\_employee\_id | Employee responsible for the visit          | INT          |

---

## Water Quality Table

Logs water quality assessments based on subjective scores and field visit data.

| Column Name                | Description                                 | Data Type |
| -------------------------- | ------------------------------------------- | --------- |
| record\_id                 | Unique ID for each water quality record     | INT       |
| subjective\_quality\_score | Quality rating (scale of 1-10)              | INT       |
| visit\_count               | Number of visits contributing to the rating | INT       |

---

## Water Source Table

Maintains details about different types of water sources, including the number of people they serve.

| Column Name                | Description                                | Data Type |
| -------------------------- | ------------------------------------------ | --------- |
| source\_id                 | Unique ID for each water source            | INT       |
| type\_of\_water\_source    | Source type (e.g., tap, well, river)       | INT       |
| number\_of\_people\_served | Estimated population served by this source | INT       |

---

## Well Pollution Table

Tracks pollution test results, recording contamination levels and potential risks to water safety.

| Column Name    | Description                         | Data Type    |
| -------------- | ----------------------------------- | ------------ |
| source\_id     | ID of the tested water source       | VARCHAR(258) |
| date           | Date of the pollution test          | DATETIME     |
| description    | Notes on the test and findings      | VARCHAR(255) |
| pollutant\_ppm | Pollution level (parts per million) | FLOAT        |

---
