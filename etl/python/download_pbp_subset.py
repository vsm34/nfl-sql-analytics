import sys, os
import pandas as pd
import nfl_data_py as nfl

# columns required from nfl_data_py PBP for analytics
REQUIRED = [
    "season","week","game_date","home_team","away_team","posteam","defteam",
    "qtr","down","ydstogo","play_type","yards_gained",
    "epa","success","first_down",
    "pass","rush","pass_attempt",
    "sack","qb_hit",
    "interception","fumble_lost",
    "penalty","penalty_yards",
    "yardline_100","touchdown","drive"
]
# optional we fill/derive
OPTIONAL = ["play_action", "punt", "penalty_team"]

FINAL_ORDER = [
    "season","week","gameday","home_team","away_team","posteam","defteam",
    "quarter","down","distance","play_type","yards_gained",
    "epa","success","first_down",
    "pass","rush","play_action","pass_attempt",
    "sack","qb_hit",
    "punt",
    "interception","fumble_lost",
    "penalty","penalty_team","penalty_yards",
    "yardline_100","touchdown","drive"
]

def get_years(argv):
    if len(argv) < 2:
        raise SystemExit("Usage: python download_pbp_subset.py 2024 [2025 ...]")
    return [int(a) for a in argv[1:]]

def ensure_optional(df):
    if "play_action" not in df.columns:
        df["play_action"] = False
    if "punt" not in df.columns:
        df["punt"] = (df["play_type"] == "punt")
    if "penalty_team" not in df.columns:
        df["penalty_team"] = pd.Series([None]*len(df), dtype="object")
    return df

def main():
    years = get_years(sys.argv)
    os.makedirs("data", exist_ok=True)
    parts = []

    for y in years:
        try:
            print(f"Downloading {y}…", flush=True)
            df = nfl.import_pbp_data([y])

            missing = [c for c in REQUIRED if c not in df.columns]
            if missing:
                print(f"  {y}: missing required {missing}, skipping.")
                continue

            keep = REQUIRED + [c for c in OPTIONAL if c in df.columns]
            df = df[keep].copy()

            df = ensure_optional(df)

            df.rename(columns={"game_date":"gameday","qtr":"quarter","ydstogo":"distance"}, inplace=True)

            # types
            int_cols = ["season","week","quarter","down","distance","yards_gained",
                        "yardline_100","drive","penalty_yards"]
            for c in int_cols:
                df[c] = pd.to_numeric(df[c], errors="coerce").astype("Int64")

            bool_cols = ["success","first_down","pass","rush","play_action","pass_attempt",
                         "sack","qb_hit","punt","interception","fumble_lost","penalty","touchdown"]
            for c in bool_cols:
                df[c] = df[c].astype("boolean")

            df["epa"] = pd.to_numeric(df["epa"], errors="coerce")

            df = df[FINAL_ORDER]
            parts.append(df)
            print(f"  {y}: {len(df):,} rows.")
        except Exception as e:
            print(f"  {y}: skipped ({e}).")

    if not parts:
        raise SystemExit("No seasons downloaded. Nothing to write.")
    out_df = pd.concat(parts, ignore_index=True)
    span = f"{years[0]}_{years[-1]}" if len(years) > 1 else f"{years[0]}"
    out = f"data/pbp_{span}_subset.csv"
    out_df.to_csv(out, index=False)
    print(f"Wrote {out} with {len(out_df):,} rows")
    print("CSV header:", ",".join(out_df.columns))

if __name__ == "__main__":
    main()
