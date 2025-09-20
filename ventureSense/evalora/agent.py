from google.adk.agents import Agent, Agent
from google.adk.tools.agent_tool import AgentTool

from .sub_agents.investor_agent import root_agent as investor_agent
from .sub_agents.market_agent import root_agent as market_agent
from .sub_agents.personality_agent import root_agent as personality_agent
from .sub_agents.risk_compliance_agent import root_agent as risk_compliance_agent
from .sub_agents.business_agent import root_agent as business_agent
from .sub_agents.product_agent import root_agent as product_agent
# from .sub_agents.technology_agent import root_agent as technology_agent
from .sub_agents.team_agent import root_agent as team_agent
from .sub_agents.finance_agent import root_agent as finance_agent
from .sub_agents.vision_agent import root_agent as vision_agent


from prompts.prompts import ORCH_SYSTEM_INSTRUCTION
from settings import *

business_agent_tool = AgentTool(agent=business_agent)
finance_agent_tool = AgentTool(agent=finance_agent)
investor_agent_tool = AgentTool(agent=investor_agent)
market_agent_tool = AgentTool(agent=market_agent)
personality_agent_tool = AgentTool(agent=personality_agent)
product_agent_tool = AgentTool(agent=product_agent)
risk_compliance_agent_tool = AgentTool(agent=risk_compliance_agent)
team_agent_tool = AgentTool(agent=team_agent)
vision_agent_tool = AgentTool(agent=vision_agent)


orchestrator = Agent(
    name="Startup_Evaluation_Orchestrator",
    model=MODEL,
    description=(
        """You are the Evalora Agent acting on behalf of an investor to evaluate a startup founder.
Your mission is to conduct a structured telephonic evaluation, gather key insights about the startup, and prepare the information for further analysis by specialized sub-agents.
You will interact with the founder professionally, ensure consent, and collect comprehensive data across all critical startup domains.
"""
    ),
    instruction=ORCH_SYSTEM_INSTRUCTION,
    output_key="orchestrator_output",
    tools= [
        business_agent_tool,
        finance_agent_tool,
        investor_agent_tool,
        market_agent_tool,
        personality_agent_tool,
        product_agent_tool,
        risk_compliance_agent_tool,
        team_agent_tool,
        vision_agent_tool,
    ]
)


root_agent = orchestrator