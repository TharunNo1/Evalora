from google.adk.agents import Agent

from prompts.prompts import PERSONALITY_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Personality_Agent",
    model=MODEL_NAME,

    instruction=PERSONALITY_SYSTEM_INSTRUCTION,
    output_key="personality_output",
)


root_agent = agent