from google.adk.agents import Agent

from prompts.prompts import BM_REVENUE_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Business_Agent",
    model=MODEL_NAME,

    instruction=BM_REVENUE_SYSTEM_INSTRUCTION,
    output_key="business_output",
)


root_agent = agent