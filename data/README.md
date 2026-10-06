# Great American Coffee Taste Test Dataset

## Dataset: https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-05-14

Our dataset is based on the Great American Coffee Taste Test, conducted in October 2023 by James Hoffmann in collaboration with Cometeer. The data were published through the TidyTuesday project on May 14, 2024.

Participants in the United States purchased a kit containing four coffees, tasted them blind during a livestream, and completed an online survey about their coffee habits, spending, demographic characteristics, and ratings of the four coffees.

The dataset contains 4,042 observations and 57 variables. Each row represents one survey submission. The variables include categorical measures of coffee habits, demographics, and spending, as well as numeric measures of self-rated coffee expertise and coffee ratings.

Because participation was voluntary and the survey was associated with a specialty-coffee YouTuber, the sample likely overrepresents people who are highly engaged with coffee. Therefore, findings should not be generalized to the broader U.S. population.

In order to retrieve the data please execute the following command while in the project root directory:

```bash
Rscript src/GetCleanData.R
```

## Codebook

| Variable | Class | Description |
|---|---|---|
| `submission_id` | character | Unique identifier for each survey submission. |
| `age` | character | Age group of the respondent. |
| `cups` | character | Number of cups of coffee consumed per day. |
| `where_drink` | character | Where the respondent typically drinks coffee. |
| `brew` | character | Method used to brew coffee. |
| `brew_other` | character | Other brewing method specified by the respondent. |
| `purchase` | character | Where the respondent typically purchases coffee. |
| `purchase_other` | character | Other coffee purchasing location specified by the respondent. |
| `favorite` | character | Favorite coffee type or brand. |
| `favorite_specify` | character | Favorite coffee specified by the respondent. |
| `additions` | character | Whether the respondent adds anything to their coffee. |
| `additions_other` | character | Other coffee addition specified by the respondent. |
| `dairy` | character | Type of dairy or dairy alternative added to coffee. |
| `sweetener` | character | Type of sweetener added to coffee. |
| `style` | character | Preferred coffee style. |
| `strength` | character | Preferred coffee strength. |
| `roast_level` | character | Preferred roast level. |
| `caffeine` | character | Preferred caffeine level. |
| `expertise` | numeric | Self-rated coffee expertise on a scale from 1 to 10. |
| `coffee_a_bitterness` | numeric | Bitterness rating for coffee A on a scale from 1 to 5. |
| `coffee_a_acidity` | numeric | Acidity rating for coffee A on a scale from 1 to 5. |
| `coffee_a_personal_preference` | numeric | Personal preference rating for coffee A on a scale from 1 to 5. |
| `coffee_a_notes` | character | Tasting notes provided for coffee A. |
| `coffee_b_bitterness` | numeric | Bitterness rating for coffee B on a scale from 1 to 5. |
| `coffee_b_acidity` | numeric | Acidity rating for coffee B on a scale from 1 to 5. |
| `coffee_b_personal_preference` | numeric | Personal preference rating for coffee B on a scale from 1 to 5. |
| `coffee_b_notes` | character | Tasting notes provided for coffee B. |
| `coffee_c_bitterness` | numeric | Bitterness rating for coffee C on a scale from 1 to 5. |
| `coffee_c_acidity` | numeric | Acidity rating for coffee C on a scale from 1 to 5. |
| `coffee_c_personal_preference` | numeric | Personal preference rating for coffee C on a scale from 1 to 5. |
| `coffee_c_notes` | character | Tasting notes provided for coffee C. |
| `coffee_d_bitterness` | numeric | Bitterness rating for coffee D on a scale from 1 to 5. |
| `coffee_d_acidity` | numeric | Acidity rating for coffee D on a scale from 1 to 5. |
| `coffee_d_personal_preference` | numeric | Personal preference rating for coffee D on a scale from 1 to 5. |
| `coffee_d_notes` | character | Tasting notes provided for coffee D. |
| `prefer_abc` | character | Coffee preference among coffees A, B, and C. |
| `prefer_ad` | character | Coffee preference between coffees A and D. |
| `prefer_overall` | character | Overall preferred coffee. |
| `wfh` | character | Whether the respondent works from home. |
| `total_spend` | character | Typical monthly spending on coffee. |
| `why_drink` | character | Reason(s) the respondent drinks coffee. |
| `why_drink_other` | character | Other reason for drinking coffee specified by the respondent. |
| `taste` | character | Whether the respondent drinks coffee because of its taste. |
| `know_source` | character | Whether the respondent knows the source of their coffee. |
| `most_paid` | character | Most the respondent has paid for a single cup of coffee. |
| `most_willing` | character | Most the respondent would be willing to pay for a single cup of coffee. |
| `value_cafe` | character | Factors that contribute to the value of a coffee shop. |
| `spent_equipment` | character | Amount spent on coffee equipment in the past five years. |
| `value_equipment` | character | Factors that contribute to the value of coffee equipment. |
| `gender` | character | Gender of the respondent. |
| `gender_specify` | character | Gender specified by the respondent. |
| `education_level` | character | Highest level of education completed. |
| `ethnicity_race` | character | Race and/or ethnicity of the respondent. |
| `ethnicity_race_specify` | character | Race and/or ethnicity specified by the respondent. |
| `employment_status` | character | Employment status of the respondent. |
| `number_children` | character | Number of children reported by the respondent. |
| `political_affiliation` | character | Political affiliation of the respondent. |

