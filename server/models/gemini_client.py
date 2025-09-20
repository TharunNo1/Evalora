import os
from typing import Dict, Optional
import google.generativeai as genai


class GeminiClient:
    def __init__(self, api_key: Optional[str] = None, model_name: str = "gemini-1.5-flash"):
        """
        GeminiService handles interaction with Google's Gemini model for document analysis.
        """
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            raise ValueError("Gemini API key is missing. Set GEMINI_API_KEY environment variable.")
        
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel(model_name)

    # ---------- Prompt Builder ----------
    def build_prompt(
        self,
        request_id: str,
        founder_name: str,
        founder_email: str,
        startup_name: str,
        docs: Dict[str, str]
    ) -> str:
        """
        Builds structured prompt for Gemini model.
        """
        return f"""
You are analyzing startup founder documents (pitch deck & checklist). Provide the following template completely filled with necessary details grounded as per documents data:

# COMPREHENSIVE INVESTOR-READY BUSINESS PLAN

request_id: {request_id}
founder_name: {founder_name}
founder_email: {founder_email}
startup_name: {startup_name}

## EXECUTIVE SUMMARY
*[This section should be written last but appears first - keep to 1-2 pages maximum]*

**Company Overview:**
- Company Name: [Collected Input]
- Mission Statement: [Collected Input]
- Vision Statement: [Collected Input]
- One-Line Value Proposition: [Collected Input]

**The Opportunity:**
- Problem Statement: [Brief description of the customer problem/need]
- Market Size: [Total Addressable Market (TAM), Serviceable Addressable Market (SAM), Serviceable Obtainable Market (SOM)]
- Unique Solution: [How your solution uniquely addresses the problem]

**Financial Highlights:**
- Funding Amount Requested: [Collected Input]
- Use of Funds: [Key categories where money will be invested]
- Revenue Projections: [Year 1, Year 2, Year 3 projected revenues]
- Expected ROI for Investors: [Projected return multiple and timeline]

**Investment Highlights:**
- Key traction metrics or early validation
- Competitive advantages
- Team credentials
- Clear path to profitability

---

## 1. COMPANY OVERVIEW & CONCEPT

### 1.1 Business Concept
**Business Name:** [Collected Input]
**Legal Structure:** [Corporation/LLC/Partnership - to be determined]
**Industry:** [Primary industry classification]
**Business Model Type:** [B2B/B2C/B2B2C/Marketplace/SaaS/etc.]

### 1.2 Mission & Vision
**Mission Statement:** [Collected Input - What the company does and why it exists]
**Vision Statement:** [Collected Input - Where the company is heading long-term]
**Core Values:** [3-5 fundamental principles that guide the business]

### 1.3 Business Idea Summary
[Collected Input - Expanded with:]
- What specific problem does this solve?
- How is this solution different from existing alternatives?
- Why is now the right time for this solution?
- What makes this scalable and defensible?

### 1.4 Unique Value Proposition
[Collected Input - Enhanced with:]
- Clear benefit statement
- Differentiation from competitors
- Quantifiable value delivered to customers
- Emotional and rational reasons customers will choose you

---

## 2. MARKET OPPORTUNITY & ANALYSIS

### 2.1 Problem Statement
**Customer Problem/Need:** [Collected Input - Expanded with:]
- How big is this problem? (quantify with data)
- How are customers currently solving this problem?
- What are the costs/inefficiencies of current solutions?
- How urgent is solving this problem for customers?

### 2.2 Target Market Analysis
**Primary Target Market:** [Collected Input - Enhanced with:]
- Detailed customer demographics/firmographics
- Customer personas (3-5 detailed profiles)
- Geographic markets (primary and expansion)
- Customer acquisition difficulty and cost

**Market Size & Opportunity:**
- Total Addressable Market (TAM): [Collected Input - Enhanced with source]
- Serviceable Addressable Market (SAM): [Realistic portion you can capture]
- Serviceable Obtainable Market (SOM): [What you can realistically achieve in 3-5 years]
- Market growth rate and trends

### 2.3 Competitive Landscape
**Main Competition:** [Collected Input - Expanded with:]

**Direct Competitors:**
- Company A: [Products, market share, strengths, weaknesses]
- Company B: [Products, market share, strengths, weaknesses]
- Company C: [Products, market share, strengths, weaknesses]

**Indirect Competitors:**
- Alternative solutions customers currently use
- Substitute products or services

**Competitive Advantages:**
- Technology advantages
- Cost advantages
- Network effects
- Brand/reputation
- Regulatory barriers
- Switching costs
- Patents/IP protection

**Competitive Matrix:**
| Feature/Capability | Your Company | Competitor A | Competitor B | Competitor C |
|-------------------|--------------|-------------|-------------|-------------|
| [Key Feature 1] | [Rating] | [Rating] | [Rating] | [Rating] |
| [Key Feature 2] | [Rating] | [Rating] | [Rating] | [Rating] |
| Price Point | [Your Price] | [Price] | [Price] | [Price] |

---

## 3. PRODUCT/SERVICE SOLUTION

### 3.1 Product/Service Description
[Collected Input - Enhanced with:]
- Detailed feature breakdown
- Technical specifications (if applicable)
- Service delivery model
- Quality standards and certifications
- Intellectual property protection

### 3.2 Core Features (MVP)
[Collected Input - Organized by priority:]

**Phase 1 Features (MVP):**
1. [Essential feature 1] - [Customer benefit]
2. [Essential feature 2] - [Customer benefit]
3. [Essential feature 3] - [Customer benefit]

**Phase 2 Features (Post-MVP):**
1. [Advanced feature 1] - [Customer benefit]
2. [Advanced feature 2] - [Customer benefit]

**Future Roadmap:**
- Year 1: [Key developments]
- Year 2: [Key developments]
- Year 3+: [Vision for product evolution]

### 3.3 Technology & Development
**Technologies/Platforms Needed:** [Collected Input - Enhanced with:]
- Core technology stack
- Infrastructure requirements
- Third-party integrations
- Security and compliance requirements
- Scalability considerations

**Development Timeline:** [Collected Input - Enhanced with:]
- MVP completion: [Date and milestones]
- Beta testing: [Timeline and metrics]
- Full product launch: [Date and success criteria]
- Major version updates: [Timeline]

### 3.4 Product Validation
**Customer Discovery:**
- Number of customer interviews conducted: [Number]
- Key insights from customer feedback
- Product-market fit indicators
- Early customer commitments or pre-orders

**Testing & Prototyping:**
- Prototype development status
- Beta testing results and feedback
- Key performance metrics from testing
- Product iteration based on feedback

---

## 4. BUSINESS MODEL & REVENUE STRATEGY

### 4.1 Revenue Model
[Collected Input - Enhanced with:]

**Primary Revenue Streams:**
1. [Revenue Stream 1]: [Description, pricing, % of total revenue]
2. [Revenue Stream 2]: [Description, pricing, % of total revenue]
3. [Revenue Stream 3]: [Description, pricing, % of total revenue]

**Revenue Model Type:**
- [ ] Subscription/SaaS
- [ ] Transaction-based
- [ ] Product sales
- [ ] Service fees
- [ ] Advertising/Marketplace
- [ ] Licensing
- [ ] Freemium
- [ ] Other: [Specify]

### 4.2 Pricing Strategy
[Collected Input - Enhanced with:]
- Pricing methodology (cost-plus, value-based, competitive)
- Price points for different customer segments
- Pricing elasticity analysis
- Discount and promotional strategies
- Price optimization plans

**Pricing Tiers/Options:**
| Tier | Target Customer | Price Point | Key Features | Expected % of Customers |
|------|----------------|-------------|--------------|------------------------|
| Basic | [Customer Type] | [Price] | [Features] | [Percentage] |
| Premium | [Customer Type] | [Price] | [Features] | [Percentage] |
| Enterprise | [Customer Type] | [Price] | [Features] | [Percentage] |

### 4.3 Unit Economics
**Key Metrics:**
- Customer Acquisition Cost (CAC): [Amount]
- Customer Lifetime Value (LTV): [Amount]
- LTV/CAC Ratio: [Ratio - should be >3:1]
- Gross Margin per Customer: [Percentage]
- Monthly Recurring Revenue (MRR) - if applicable
- Average Revenue Per User (ARPU): [Amount]

---

## 5. GO-TO-MARKET STRATEGY & SALES

### 5.1 Launch Strategy
[Collected Input - Enhanced with:]
- Soft launch plan (beta customers, limited geography)
- Full market launch timeline
- Launch success metrics and KPIs
- Marketing campaign strategy
- PR and communications plan

### 5.2 Customer Acquisition Strategy
**Customer Acquisition Channels:** [Collected Input - Enhanced with:]

**Primary Channels:**
1. [Channel 1]: [Cost, conversion rate, scalability]
2. [Channel 2]: [Cost, conversion rate, scalability]
3. [Channel 3]: [Cost, conversion rate, scalability]

**Channel Strategy by Phase:**
- **Months 1-6:** [Focus channels and reasons]
- **Months 7-12:** [Focus channels and reasons]
- **Year 2+:** [Focus channels and reasons]

**Sales Process:**
- Lead generation strategy
- Lead qualification criteria
- Sales cycle length: [Duration]
- Conversion rates at each stage
- Sales team structure and compensation

### 5.3 Marketing Strategy
**Brand Positioning:** [How you want to be perceived in the market]

**Marketing Mix:**
- **Product:** [Key differentiators to highlight]
- **Price:** [Pricing strategy messaging]
- **Place:** [Distribution and sales channels]
- **Promotion:** [Marketing communications strategy]

**Digital Marketing Strategy:**
- Content marketing plan
- Social media strategy
- Search engine optimization (SEO)
- Paid advertising (Google Ads, social media ads)
- Email marketing and automation
- Influencer and partnership marketing

**Customer Retention Strategy:**
- Onboarding process
- Customer success programs
- Loyalty programs or incentives
- Upselling and cross-selling strategies

---

## 6. OPERATIONS PLAN

### 6.1 Operational Model
**Business Operations:**
- Key operational processes
- Service/product delivery model
- Quality control measures
- Customer service approach
- Scalability plans

### 6.2 Supply Chain & Vendors
**Key Suppliers/Partners:** [If applicable]
- Primary suppliers and backup options
- Key partnership agreements
- Supplier risk mitigation strategies
- Cost management and negotiation strategies

### 6.3 Technology Infrastructure
**IT Systems & Infrastructure:**
- Core technology platforms
- Data management and analytics
- Cybersecurity measures
- Disaster recovery plans
- Scalability and performance planning

### 6.4 Location & Facilities
**Physical Infrastructure:**
- Office/facility requirements
- Location strategy (remote, hybrid, physical)
- Equipment and asset needs
- Expansion plans

---

## 7. MANAGEMENT TEAM & ORGANIZATION

### 7.1 Founder Background
[Collected Input - Enhanced with:]
- Detailed professional background
- Relevant industry experience
- Previous entrepreneurial experience
- Key achievements and credentials
- Education and certifications
- Why this founder is uniquely positioned to solve this problem

### 7.2 Current Team Structure
**Planned Team & Roles:** [Collected Input - Enhanced with:]

**Current Team:**
- [Name]: [Title] - [Background, key skills, equity %]
- [Name]: [Title] - [Background, key skills, equity %]

**Organizational Chart:** [Visual representation of reporting structure]

### 7.3 Hiring Plan
**Key Positions to Fill:**
| Role | Timeline | Salary Range | Equity % | Priority | Key Qualifications |
|------|----------|-------------|----------|----------|-------------------|
| [Role 1] | [Month] | [Range] | [%] | [High/Medium/Low] | [Requirements] |
| [Role 2] | [Month] | [Range] | [%] | [High/Medium/Low] | [Requirements] |

**Team Development Strategy:**
- Recruiting strategy and channels
- Company culture development
- Employee retention strategies
- Performance management systems

### 7.4 Advisory Board & Mentors
**Advisors/Partners:** [Collected Input - Enhanced with:]
- [Name]: [Background, expertise, how they help]
- [Name]: [Background, expertise, how they help]

**Advisory Compensation:**
- Typical equity grants for advisors: [0.1% - 1.0%]
- Advisory agreement terms
- Expected time commitment and contributions

### 7.5 Corporate Governance
**Board Structure:**
- Board composition (founders, investors, independents)
- Board meeting frequency and format
- Key committees (audit, compensation, etc.)
- Decision-making processes

---

## 8. FINANCIAL PROJECTIONS & ANALYSIS

### 8.1 Financial Summary
**Key Financial Highlights:**
- Break-even timeline: [Month/Year]
- Cash flow positive: [Month/Year]
- Projected revenue at 3 years: [Amount]
- Projected profit margin at maturity: [Percentage]

### 8.2 Revenue Projections
**Financial Goals:** [Collected Input - Enhanced with detailed breakdown]

| Metric | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 |
|--------|--------|--------|--------|--------|--------|
| Revenue | [Amount] | [Amount] | [Amount] | [Amount] | [Amount] |
| Gross Profit | [Amount] | [Amount] | [Amount] | [Amount] | [Amount] |
| Gross Margin % | [%] | [%] | [%] | [%] | [%] |
| EBITDA | [Amount] | [Amount] | [Amount] | [Amount] | [Amount] |
| Net Income | [Amount] | [Amount] | [Amount] | [Amount] | [Amount] |
| Customers | [Number] | [Number] | [Number] | [Number] | [Number] |

### 8.3 Expense Breakdown
**Key Expenses:** [Collected Input - Enhanced with detailed categories]

**Fixed Costs (Monthly):**
- Salaries and benefits: [Amount]
- Office rent and utilities: [Amount]
- Software and subscriptions: [Amount]
- Insurance: [Amount]
- Legal and accounting: [Amount]
- Marketing (fixed): [Amount]
- Other fixed costs: [Amount]

**Variable Costs (% of Revenue):**
- Cost of goods sold: [%]
- Sales commissions: [%]
- Marketing (performance-based): [%]
- Payment processing: [%]
- Customer service: [%]

### 8.4 Cash Flow Analysis
**Monthly Cash Flow Projections (Year 1):**
[Monthly breakdown showing cash inflows, outflows, and ending balance]

**Cash Flow Runway:**
- Current cash on hand: [Amount]
- Monthly burn rate: [Amount]
- Runway without funding: [Months]
- **Runway (How long funds will last):** [Collected Input]

### 8.5 Financial Assumptions
**Key Assumptions Behind Projections:**
- Customer acquisition rate and cost
- Revenue per customer and growth rates
- Pricing assumptions and changes
- Cost inflation rates
- Market penetration rates
- Seasonality factors

### 8.6 Scenario Analysis
**Financial Scenarios:**

**Best Case (25% probability):**
- Key assumptions and resulting metrics
- Revenue and profitability outcomes

**Base Case (50% probability):**
- Most likely assumptions and outcomes
- Conservative but achievable projections

**Worst Case (25% probability):**
- Conservative assumptions and stress testing
- Minimum viable outcomes and survival strategies

---

## 9. FUNDING REQUEST & INVESTMENT

### 9.1 Funding Requirements
**Estimated Total Budget:** [Collected Input]
**Personal Investment:** [Collected Input - Enhanced with source of funds]
**Expected Funding Needs:** [Collected Input]

**Funding Round Details:**
- **Amount Raising:** [Specific amount with range]
- **Valuation:** [Pre-money and post-money if known]
- **Equity Offered:** [Percentage]
- **Type of Securities:** [Common stock, preferred stock, convertible notes]
- **Timeline:** [Funding completion target date]

### 9.2 Use of Funds
**Detailed Use of Proceeds:**
| Category | Amount | Percentage | Timeline | Key Milestones |
|----------|--------|------------|----------|---------------|
| Product Development | [Amount] | [%] | [Months] | [Deliverables] |
| Marketing & Sales | [Amount] | [%] | [Months] | [Targets] |
| Team Expansion | [Amount] | [%] | [Months] | [Hires] |
| Operations | [Amount] | [%] | [Months] | [Capabilities] |
| Working Capital | [Amount] | [%] | [Months] | [Buffer] |
| **Total** | **[Total Amount]** | **100%** | | |

### 9.3 Investment Returns
**Investor Value Proposition:**
- Expected return multiple: [X times investment]
- Timeline to exit: [Years]
- Exit strategy options: [IPO, acquisition, management buyout]
- Comparable company valuations and exits

**Key Value Drivers:**
- Market opportunity size and growth
- Competitive advantages and moat
- Scalable business model
- Experienced team
- Clear path to profitability

### 9.4 Exit Strategy
**Potential Exit Scenarios:**
1. **Strategic Acquisition:** [Target acquirers, timeline, valuation multiples]
2. **Financial Acquisition:** [Private equity, timeline, valuation multiples]
3. **IPO:** [Market cap requirements, timeline, precedents]
4. **Management Buyout:** [Conditions and structure]

**Comparable Transactions:**
- Recent acquisitions in the industry
- Valuation multiples (revenue, EBITDA)
- Strategic rationale for acquisitions

---

## 10. RISK ANALYSIS & MITIGATION

### 10.1 Business Risks
**Market Risks:**
- Market adoption slower than expected
- Economic downturn affecting demand
- Regulatory changes impacting the industry
- Competitive response from established players

**Operational Risks:**
- Key personnel departure
- Technology failures or security breaches
- Supply chain disruptions
- Scalability challenges

**Financial Risks:**
- Inability to raise additional funding
- Cash flow shortfalls
- Customer concentration risk
- Currency or interest rate exposure

### 10.2 Risk Mitigation Strategies
**For Each Major Risk:**
- Probability assessment (High/Medium/Low)
- Impact assessment (High/Medium/Low)
- Specific mitigation strategies
- Contingency plans
- Monitoring and early warning indicators

### 10.3 Legal & Compliance
**Legal/Compliance Needs:** [Collected Input - Enhanced with:]
- Regulatory requirements and licensing
- Intellectual property protection strategy
- Data privacy and security compliance
- Employment law considerations
- Contract and liability management

**Insurance Coverage:**
- General liability insurance
- Professional liability insurance
- Cyber liability insurance
- Key person insurance
- Directors and officers insurance

---

## 11. MILESTONES & KEY PERFORMANCE INDICATORS

### 11.1 Business Milestones
**Milestones & KPIs:** [Collected Input - Enhanced with timeline]

**6-Month Milestones:**
- [Milestone 1]: [Specific, measurable target]
- [Milestone 2]: [Specific, measurable target]
- [Milestone 3]: [Specific, measurable target]

**12-Month Milestones:**
- [Milestone 1]: [Specific, measurable target]
- [Milestone 2]: [Specific, measurable target]
- [Milestone 3]: [Specific, measurable target]

**24-Month Milestones:**
- [Milestone 1]: [Specific, measurable target]
- [Milestone 2]: [Specific, measurable target]
- [Milestone 3]: [Specific, measurable target]

### 11.2 Key Performance Indicators (KPIs)
**Customer Metrics:**
- Customer acquisition rate (customers/month)
- Customer acquisition cost (CAC)
- Customer lifetime value (LTV)
- Customer retention rate
- Net Promoter Score (NPS)
- Monthly/Annual Recurring Revenue (MRR/ARR)

**Financial Metrics:**
- Revenue growth rate (month-over-month, year-over-year)
- Gross margin percentage
- Monthly burn rate
- Months of runway remaining
- Cash conversion cycle

**Operational Metrics:**
- Product development velocity
- Team productivity metrics
- Customer support response times
- System uptime and performance

### 11.3 Reporting and Monitoring
**Investor Reporting:**
- Monthly financial reports
- Quarterly board meetings
- Annual strategic reviews
- Ad-hoc updates for major developments

**Dashboard and Analytics:**
- Real-time KPI dashboard
- Monthly performance reviews
- Variance analysis against projections
- Corrective action plans

---

## 12. ADDITIONAL CONSIDERATIONS

### 12.1 Environmental, Social & Governance (ESG)
**Sustainability Initiatives:**
- Environmental impact and sustainability measures
- Social responsibility programs
- Diversity and inclusion policies
- Ethical business practices

### 12.2 Digital Transformation
**Technology Adoption:**
- Digital infrastructure and capabilities
- Data analytics and business intelligence
- Automation and AI integration opportunities
- Digital customer experience enhancements

### 12.3 Scalability Planning
**Growth Preparation:**
- Systems and processes for scale
- International expansion possibilities
- Strategic partnership opportunities
- Platform and ecosystem development

---

## APPENDICES

### Appendix A: Market Research Data
- Industry reports and analysis
- Customer survey results
- Competitive intelligence
- Market size calculations and sources

### Appendix B: Financial Models
- Detailed financial projections (monthly for Year 1, quarterly for Years 2-3)
- Sensitivity analysis
- Scenario modeling
- Unit economics calculations

### Appendix C: Technical Documentation
- Product specifications
- Technology architecture
- Development roadmap
- Intellectual property portfolio

### Appendix D: Legal Documents
- Corporate structure documents
- Key contracts and agreements
- Regulatory compliance documentation
- Intellectual property registrations

### Appendix E: Team Documentation
- Detailed founder and team resumes
- Organizational chart
- Advisory board profiles
- Recruitment and hiring plans

### Appendix F: Supporting Materials
- Letters of intent from customers
- Partnership agreements
- Press coverage and testimonials
- Product demos or prototypes (if available)

---

## DOCUMENT CONTROL

**Document Version:** 1.0
**Last Updated:** [Date]
**Prepared By:** [Founder Name]
**Reviewed By:** [Advisory Team]
**Approved By:** [Board/Founders]

**Confidentiality Notice:**
This business plan contains confidential and proprietary information. Any reproduction or distribution of this document, in whole or in part, without written consent is strictly prohibited.

**Contact Information:**
[Founder Name]
[Title]
[Company Name]
[Phone Number]
[Email Address]
[Company Address]

---

*This comprehensive business plan template is designed to meet institutional investor requirements and due diligence standards. Each section should be thoroughly completed with specific, measurable data and realistic projections based on solid market research and financial analysis.*

    Here are the contents of various documents:
######## Founder Checklist: ###########
    {docs.get("founderChecklist", "Not Available")}
######## Pitch deck: ###########
    {docs.get("pitchDeck", "Not Available")}
######## Additional Document 1: ###########
    {docs.get("otherDoc1", "Not Applicable")}
######## Additional Document 2: ###########
   {docs.get("otherDoc2", "Not Applicable")}

    """
 

    # ---------- Gemini Interaction ----------
    async def analyze_documents(
        self,
        request_id: str,
        founder_name: str,
        founder_email: str,
        startup_name: str,
        docs: Dict[str, str],
    ) -> str:
        """
        Extracts text, builds prompt, and queries Gemini model.
        `docs` should be a dict with file paths: { "founderChecklist": path, ... }
        """

        prompt = self.build_prompt(
            request_id=request_id,
            founder_name=founder_name,
            founder_email=founder_email,
            startup_name=startup_name,
            docs=docs,
        )

        response = self.model.generate_content(prompt)
        return response.text
