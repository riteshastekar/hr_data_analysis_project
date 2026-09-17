# HR Attrition Analysis (SQL + Power BI)

End-to-end HR attrition analysis on a ~22,000-employee dataset. SQL Server is used to clean raw data and build a set of reusable KPI views; Power BI turns those views into an interactive dashboard covering headcount, demographics, and turnover.

## Objective

Identify which departments, demographics, and time periods have the highest employee turnover, and surface workforce composition trends to support HR decision-making.

## Tools Used

- **SQL Server** — data cleaning, transformation, and KPI views
- **Power BI** — interactive dashboard and visualizations

## Data

Source file: `Human_Resources.csv` (~22,000 employee records) with fields including demographics (gender, race, age), job info (department, job title, location), and employment dates (hire date, termination date).

> If this dataset is a public/Kaggle dataset, credit the original source here and link it.

## Data Cleaning (SQL)

Raw data came in with inconsistent formatting that had to be resolved before analysis:

- **Mixed date formats** — `birthdate` and `hire_date` contained both `M/D/YYYY` and `MM-DD-YYYY` styles in the same column (an Excel auto-formatting quirk that reformats only day-ambiguous dates). Both were parsed explicitly using fixed `CONVERT` styles rather than relying on implicit casting, so parsing doesn't depend on server locale settings.
- **Termination timestamps** — `termdate` values were stored as `yyyy-mm-dd hh:mm:ss UTC` strings; these were parsed into `datetime2`, with rows lacking a valid timestamp treated as still-employed (`NULL`).
- **Future-dated terminations** — the source data contains placeholder termination dates in the future (e.g. `2029-10-29`). All KPI queries filter with `termdate <= GETDATE()` to exclude these from turnover calculations.
- **Derived `age` column** — calculated from `birthdate` using full elapsed years (accounting for whether the birthday has occurred yet this calendar year), rather than a naive year subtraction.

Full cleaning logic: [`sql/02_load_and_clean_data.sql`](sql/02_load_and_clean_data.sql)

## SQL Views

Each KPI question is implemented as its own SQL view, so Power BI (or any BI tool) can connect directly without re-running query logic.

| View | Business question |
|---|---|
| `gender` | Gender breakdown of active employees |
| `race_breakdown` | Race breakdown of active employees |
| `age_distribution` | Age group distribution of active employees |
| `hq_VS_re` | Headquarters vs. remote headcount |
| `vw_avg_length_of_employment` | Average tenure of terminated employees |
| `vw_gender_distribution_by_dept_jobtitle` | Gender distribution by department and job title |
| `vw_gender_distribution_by_dept` | Gender distribution by department |
| `vw_jobtitle_distribution` | Headcount by job title |
| `vw_termination_rate_by_dept` | Termination rate by department |
| `vw_employee_distribution_by_state` | Employee distribution by state |
| `vw_employee_distribution_by_city` | Employee distribution by city |
| `vw_employee_count_change_over_time` | Hires vs. terminations by year |
| `vw_avg_tenure_by_dept` | Average tenure by department |
| `vw_gender_wise_terminations_hires` | Termination rate by gender |
| `vw_age_wise_terminations_hires` | Termination rate by age |
| `vw_race_wise_terminations_hires` | Termination rate by race |

Full view definitions: [`sql/03_kpi_views.sql`](sql/03_kpi_views.sql)

## Dashboard Preview

![Workforce Overview](screenshots/dashboard_overview.png)
*Gender, location, age, department, and race breakdowns of the active workforce.*

![Geographic & Department Distribution](screenshots/dashboard_geo_dept.png)
*State-wise map and department-wise headcount distribution.*

![Hiring & Tenure Trends](screenshots/dashboard_hires_tenure.png)
*Year-over-year hires vs. terminations, and average tenure by department.*

![Termination Rate Analysis](screenshots/dashboard_termination_rates.png)
*Termination rate broken down by gender, age, department, year, and race.*

## Key Insights

**Workforce composition**
- The active workforce is fairly balanced by gender: ~9,628 male, ~8,455 female, ~502 non-conforming employees.
- ~75% of employees work at Headquarters, ~25% remote.
- The largest age group is 35–44, followed closely by 25–34 and 45–54; 18–24 is the smallest group.
- White employees make up the largest race group (~5.2K), followed by Two or More Races and Black or African American (~3.0K each).
- Engineering is by far the largest department (~6K employees), followed by Sales, Training, and Services.
- Ohio (headquarters state) accounts for the largest concentration of employees.

**Turnover / attrition**
- Overall termination rate varies by department: **Auditing and Legal have the highest termination rates** (~19% and ~15%+), while Marketing and Business Development have the lowest (~11%).
- Termination rate is fairly close across gender (Female 13.3%, Male 12.9%, Non-Conforming 11.4%).
- Termination rate by race ranges from ~12.2% (Hispanic or Latino) to ~14.6% (Native Hawaiian or Other Pacific Islander), a relatively narrow spread.
- **Termination rate has been declining year-over-year since ~2010**, dropping from ~18–20% down to under 10% by 2020.
- Average tenure is fairly consistent across departments (~8 years), with Sales slightly higher (9 years) and Product Management slightly lower (7 years).
- Hires grew steadily and plateaued after ~2005; terminations have trended downward more sharply since ~2010, resulting in a widening gap between hires and terminations (i.e., a growing, more stable workforce).

## Project Structure

```
hr-attrition-analysis/
├── README.md
├── data/
│   └── Human_Resources.csv
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_load_and_clean_data.sql
│   └── 03_kpi_views.sql
├── powerbi/
│   └── hr_dashboard.pbix
└── screenshots/
    ├── dashboard_overview.png
    ├── dashboard_geo_dept.png
    ├── dashboard_hires_tenure.png
    └── dashboard_termination_rates.png
```

## How to Run

1. Run `sql/01_create_table.sql` to create the `hr` table.
2. Update the file path in `sql/02_load_and_clean_data.sql` (`BULK INSERT ... FROM '...'`) to point to your local copy of `Human_Resources.csv`, then run it to load and clean the data.
3. Run `sql/03_kpi_views.sql` to create all KPI views.
4. Open `powerbi/hr_dashboard.pbix` in Power BI Desktop and point the data source to your SQL Server instance to refresh the visuals.
