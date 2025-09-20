from google.adk.agents import Agent

from prompts.prompts import VISION_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Vision_Agent",
    model=MODEL_NAME,

    instruction=VISION_SYSTEM_INSTRUCTION,
    output_key="vision_output",
)


root_agent = agent