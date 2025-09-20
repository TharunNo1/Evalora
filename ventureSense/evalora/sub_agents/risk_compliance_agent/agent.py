from google.adk.agents import Agent

from prompts.prompts import RISK_COMPLIANCE_SYSTEM_INSTRUCTION
from settings import *

agent = Agent(
    name="Risk_Compliance_Agent",
    model=MODEL_NAME,

    instruction=RISK_COMPLIANCE_SYSTEM_INSTRUCTION,
    output_key="risk_compliance_output",
)


root_agent = agent