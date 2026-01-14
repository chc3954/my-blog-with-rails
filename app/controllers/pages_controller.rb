class PagesController < ApplicationController
  def home
  end

  def about
    @menu_items = [
      { id: "profile", label: "Profile", icon: "💫" },
      { id: "skills", label: "Skills", icon: "⚡" },
      { id: "experience", label: "Experience", icon: "🚀" },
      { id: "projects", label: "Projects", icon: "💻" },
      { id: "contact", label: "Contact", icon: "📫" }
    ]

    @content = {
      profile: {
        title: "Software Developer",
        description:
          "Passionate full-stack developer and DevOps engineer specializing in modern web technologies and cloud infrastructure. I have a strong background in building scalable applications, automating deployment pipelines, and managing cloud environments."
      },
      skills: {
        title: "Technical Skills",
        categories: [
          {
            name: "Frontend",
            items: [ "React", "Next.js", "TypeScript" ]
          },
          {
            name: "Backend",
            items: [ "NestJS", "Express.js", "Ruby on Rails", "GraphQL", "REST API" ]
          },
          {
            name: "DevOps & Cloud",
            items: [ "Docker", "Kubernetes", "Terraform", "Ansible", "Jenkins", "ArgoCD", "AWS" ]
          },
          {
            name: "Other",
            items: [ "Unity", "Git", "Linux" ]
          }
        ]
      },
      experience: {
        title: "Professional Experience",
        items: [
          {
            role: "Software Developer",
            company: "VARLab",
            period: "Sep 2023 - Aug 2024",
            achievements: [
              "Worked in the vConestoga team to develop the online class environment for Conestoga College using the Scrum methodology",
              "Built the DLX application integration environment and developing multi-tracked conference applications"
            ]
          },
          {
            role: "Naval Officer",
            company: "Republic of Korea Navy",
            period: "Mar 2016 - Feb 2021",
            achievements: [
              "Worked on various warships including battleships, patrol killer, and minesweeping ship",
              "Managed the facilities and supplies as a flotilla assistant chief of staff for logistics",
              "Received commendation for my achievements"
            ]
          }
        ]
      },
      projects: {
        title: "Notable Projects",
        items: [
          {
            name: "OnePlate Cloud",
            description:
              "Self-hosted image management system replacing terminal-based uploads with a secure web GUI",
            tech: [ "React", "Express.js" ],
            status: "Completed",
            url: "https://github.com/chc3954/one-plate-cloud"
          },
          {
            name: "JukeVibes",
            description: "Real-time web jukebox application",
            tech: [ "React", "Express.js", "Supabase Database", "Prisma" ],
            status: "Completed",
            url: "https://github.com/Saravia95/Group11-Capstone"
          },
          {
            name: "Yuber Eats",
            description: "Full-stack Uber Eats clone application",
            tech: [ "React", "NestJS", "GraphQL", "TypeORM" ],
            status: "Completed",
            url: "https://github.com/chc3954/uber-eats-clone"
          },
          {
            name: "Smart Quotation Tool",
            description: "Intelligent product recommendation system -Seneca Hackathon (2023) Finalist",
            tech: [ "ASP.NET", "MVC", "SQL Server" ],
            status: "Completed"
          }
        ]
      },
      contact: {
        title: "Get in Touch",
        email: "chc3954@gmail.com",
        phone: "+1 (519) 778-6762",
        linkedin: "www.linkedin.com/in/hc-cho"
      }
    }
  end
end
