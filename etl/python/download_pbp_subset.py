import sys, os
import pandas as pd
import nfl_data_py as nfl

NEEDED_RAW = [
    "season","week","game_date","home_team","away_team",
    "posteam","defteam","qtr","down","ydstogo","play_type","yards_gained"
]

FINAL_ORDER = [
    "season","week","gameday","home_team","away_team",
    "posteam","defteam","quarter","down","distance","play_type","yards_gained"
]

def get_years(argv):
    if len(argv) < 2:
        raise SystemExit("Usage: python download_pbp_subset.py 2024 [2025 ...]")
    return [int(a) for a in argv[1:]]

def main():
    years = get_years(sys.argv)
    os.makedirs("data", exist_ok=True)

    parts = []
    for y in years:
        try:
            print(f"Downloading {y}…", flush=True)
            df = nfl.import_pbp_data([y])  # get all, subset ourselves
            if not set(NEEDED_RAW).issubset(df.columns):
                missing = [c for c in NEEDED_RAW if c not in df.columns]
                print(f"  {y}: missing columns {missing}, skipping.")
                continue
            df = df[NEEDED_RAW].copy()

            # rename + normalize types and order
            df.rename(columns={"game_date":"gameday","qtr":"quarter","ydstogo":"distance"}, inplace=True)
            df.dropna(subset=["posteam","defteam","down","distance","play_type","yards_gained"], inplace=True)

            df["gameday"] = pd.to_datetime(df["gameday"]).dt.date
            # force integer types so CSV has no decimals
            for c in ["season","week","quarter","down","distance","yards_gained"]:
                df[c] = pd.to_numeric(df[c], errors="coerce").astype("Int64")

            # keep only expected order
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
