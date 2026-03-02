# Sweet, Sweet Revenge: NBA Revenge Game Analysis

**Maggie Chen, Emily Hebert, Jade Lightfoot, Shashwat Mishra**  

---

## The Question

The NBA sells more than basketball — it sells stories. One of the most persistent narratives in sports media is the "revenge game": a player, freshly traded away from a team they spent years with, returns and puts on a show fueled by emotion and spite.

But does the data actually back that up?

We set out to test whether NBA players who were traded from a team (after spending 3+ years there) perform significantly differently when they face that former team, compared to games against opponents of similar strength.

---

## Approach

For each player, we identified their revenge games and used **nearest-neighbor matching** (via R's `MatchIt` package) to pair each one with a comparable non-revenge game — controlling for minutes played, shot attempts, home/away status, and opponent win percentage. The difference in points, rebounds, and assists between each matched pair is the core unit of analysis.

```r
m <- matchit(
  is_revenge ~ minutes + field_goals_attempted + home_away + opp_win_pct,
  data = match_df,
  method = "nearest",
  ratio = 1
)
```

We then ran one-sample t-tests on those differences across 20 players and 55 total revenge games to assess statistical significance.

Data came from **Basketball Reference** (player movement and season stats) and the **HoopR package** in R (game-level box scores).

---

## What We Found

Across all three outcome variables, the results were clear: no statistically significant difference.

| Statistic | Mean Difference | p-value |
|-----------|----------------|---------|
| Points    | +0.93           | 0.61    |
| Rebounds  | -0.20           | 0.72    |
| Assists   | -0.46           | 0.30    |

Individual players like Donovan Mitchell and Kyrie Irving showed scoring spikes in their revenge games, but these were counterbalanced by underperformances elsewhere. At the league level, the revenge game narrative does not hold up statistically.

---

## Read More

- Full written report: [`Final_Project_Written_Report.pdf`](Final_Project_Written_Report.pdf)
- Presentation slides: [`Revenge Analysis Slides.pdf`](Sports_Analytics_Presentation.pdf)

---

## Repo Structure

```
.
├── data/
│   ├── player_csvs/       # Per-player matched game differentials
│   └── combined_data.csv  # Merged dataset used for t-tests
├── scripts/
│   └── template.Rmd       # Matching template (run per player)
├── report/
│   ├── Final_Project_Written_Report.pdf
│   └── Sports_Analytics_Presentation.pdf
└── README.md
```

---

## Tools

R, `MatchIt`, `HoopR`, `janitor`, `ggplot2`
