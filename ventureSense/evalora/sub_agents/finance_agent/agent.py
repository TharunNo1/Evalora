from google.adk.agents import Agent

from prompts.prompts import FINANCE_FUND_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Finance_Agent",
    model=MODEL_NAME,
    instruction=FINANCE_FUND_SYSTEM_INSTRUCTION,
    output_key="finance_output"
)


root_agent = agent