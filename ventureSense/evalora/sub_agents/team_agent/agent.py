from google.adk.agents import Agent

from prompts.prompts import TEAM_HIRING_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Team_Agent",
    model=MODEL_NAME,

    instruction=TEAM_HIRING_SYSTEM_INSTRUCTION,
    output_key="business_output",
)


root_agent = agent