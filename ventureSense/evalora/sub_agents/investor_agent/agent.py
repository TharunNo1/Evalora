from google.adk.agents import Agent

from prompts.prompts import INVESTOR_FIT_EXIT_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Investor_Agent",
    model=MODEL_NAME,

    instruction=INVESTOR_FIT_EXIT_SYSTEM_INSTRUCTION,
    output_key="investor_output",
)


root_agent = agent