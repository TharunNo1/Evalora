from google.adk.agents import Agent

from prompts.prompts import MARKET_COMPETITION_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Market_Agent",
    model=MODEL_NAME,

    instruction=MARKET_COMPETITION_SYSTEM_INSTRUCTION,
    output_key="Market_output",
)


root_agent = agent