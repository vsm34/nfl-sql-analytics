import os
DB_DSN = os.getenv(
    "DB_DSN",
    "postgresql://postgres:postgres@127.0.0.1:5432/nfl?sslmode=disable"
)
import streamlit as st
import pandas as pd
import psycopg
from dotenv import load_dotenv

load_dotenv()

DB_DSN = f"dbname={os.getenv('POSTGRES_DB','nfl')} user={os.getenv('POSTGRES_USER','postgres')} " \
         f"password={os.getenv('POSTGRES_PASSWORD','postgres')} host={os.getenv('POSTGRES_HOST','localhost')} " \
         f"port={os.getenv('POSTGRES_PORT','5432')}"

@st.cache_data(ttl=60)
def q(sql, params=None):
    with psycopg.connect(DB_DSN) as conn:
        return pd.read_sql(sql, conn, params=params)

st.set_page_config(page_title="NFL SQL Analytics", layout="wide")
st.title("🏈 NFL SQL Analytics — Dashboard (MVP)")

tab1, tab2, tab3, tab4 = st.tabs(["League Overview", "Team Explorer", "Situational & Discipline", "Explore Views"])

with tab1:
    col1, col2, col3 = st.columns(3)
    df_epa = q("SELECT * FROM mv_epa_per_play ORDER BY epa_per_play DESC LIMIT 10;")
    df_ypp = q("SELECT * FROM vw_yards_per_play ORDER BY ypp DESC LIMIT 10;")
    df_tov = q("SELECT * FROM vw_turnover_rate ORDER BY turnover_rate ASC LIMIT 10;")

    col1.metric("Top EPA/play team", df_epa.iloc[0]["team_abbr"], f"{df_epa.iloc[0]['epa_per_play']:.3f}")
    col2.metric("Top YPP team", df_ypp.iloc[0]["team_abbr"], f"{df_ypp.iloc[0]['ypp']:.2f}")
    col3.metric("Lowest TO rate", df_tov.iloc[0]["team_abbr"], f"{df_tov.iloc[0]['turnover_rate']:.3f}")

    st.subheader("Leaders")
    c1, c2, c3 = st.columns(3)
    c1.dataframe(df_epa, use_container_width=True)
    c2.dataframe(df_ypp, use_container_width=True)
    c3.dataframe(df_tov, use_container_width=True)

with tab2:
    teams = q("SELECT DISTINCT team_abbr FROM teams ORDER BY team_abbr;")["team_abbr"].tolist()
    seasons = q("SELECT DISTINCT year FROM seasons ORDER BY year;")["year"].tolist()
    colA, colB = st.columns(2)
    team = colA.selectbox("Team", teams, index=max(0, teams.index("KC")) if "KC" in teams else 0)
    season = colB.selectbox("Season", seasons, index=len(seasons)-1)

    st.markdown("**Yards/Game (season)**")
    st.dataframe(q("""
        SELECT * FROM vw_team_yards_per_game_by_season
        WHERE team_abbr=%s AND season=%s
        ORDER BY yards_per_game DESC
    """, (team, season)), use_container_width=True)

    st.markdown("**3rd & 4th Down Conversion (team)**")
    st.dataframe(q("""
        SELECT * FROM vw_conversion_by_down
        WHERE team_abbr=%s AND down IN (3,4)
        ORDER BY down
    """, (team,)), use_container_width=True)

    st.markdown("**Red-Zone (drive-based)**")
    st.dataframe(q("""
        SELECT * FROM vw_redzone_drives WHERE team_abbr=%s;
    """, (team,)), use_container_width=True)

with tab3:
    c1, c2, c3 = st.columns(3)
    c1.markdown("**Pressure & Sack Rate**")
    c1.dataframe(q("""
        SELECT * FROM vw_pressure_sack_rate
        ORDER BY pressure_rate DESC NULLS LAST LIMIT 15
    """), use_container_width=True)

    c2.markdown("**Explosive Play Rate**")
    c2.dataframe(q("""
        SELECT * FROM vw_explosive_play_rate
        ORDER BY explosive_rate DESC LIMIT 15
    """), use_container_width=True)

    c3.markdown("**Penalty Yards (Offense/Defense)**")
    c3.dataframe(q("""
        SELECT t.team_abbr,
               o.offense_penalty_yards_per_game,
               d.defense_penalty_yards_per_game
        FROM vw_penalty_yards_offense o
        JOIN vw_penalty_yards_defense d USING (team_abbr)
        JOIN teams t USING (team_abbr)
        ORDER BY (o.offense_penalty_yards_per_game + d.defense_penalty_yards_per_game) DESC
        LIMIT 15
    """), use_container_width=True)

with tab4:
    st.markdown("**Explore any view**")
    all_views = q("""
        SELECT viewname FROM pg_catalog.pg_views
        WHERE schemaname = 'public' AND viewname LIKE 'vw_%'
        ORDER BY viewname;
    """)["viewname"].tolist()
    choice = st.selectbox("View", all_views)
    st.dataframe(q(f"SELECT * FROM {choice} LIMIT 500;"), use_container_width=True)
