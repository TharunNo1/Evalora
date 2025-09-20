from google.adk.agents import Agent

from prompts.prompts import PRODUCT_TECH_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Product_Agent",
    model=MODEL_NAME,

    instruction=PRODUCT_TECH_SYSTEM_INSTRUCTION,
    output_key="product_output",
)


root_agent = agent