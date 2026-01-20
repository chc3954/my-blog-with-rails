class PagesController < ApplicationController
  def home
  end

  def about
    @menu_items = [
      { id: "profile", label: "Profile", icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" /></svg>'.html_safe },
      { id: "skills", label: "Skills", icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 3v1.5M4.5 8.25H3m18 0h-1.5M4.5 12H3m18 0h-1.5m-15 3.75H3m18 0h-1.5M8.25 19.5V21M12 3v1.5m0 15V21m3.75-18v1.5m0 15V21m-9-1.5h10.5a2.25 2.25 0 0 0 2.25-2.25V6.75a2.25 2.25 0 0 0-2.25-2.25H6.75A2.25 2.25 0 0 0 4.5 6.75v10.5a2.25 2.25 0 0 0 2.25 2.25Zm.75-12h9v9h-9v-9Z" /></svg>'.html_safe },
      { id: "experience", label: "Experience", icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="M20.25 14.15v4.25c0 1.094-.787 2.036-1.872 2.18-2.087.277-4.216.42-6.378.42s-4.291-.143-6.378-.42c-1.085-.144-1.872-1.086-1.872-2.18v-4.25m16.5 0a2.18 2.18 0 0 0 .75-1.661V8.706c0-1.081-.768-2.015-1.837-2.175a48.114 48.114 0 0 0-3.413-.387m4.5 8.006c-.194.165-.42.295-.67.38m-17.25-.38l-.376-7.446V6.532c0-1.081.768-2.015 1.837-2.175a48.111 48.111 0 0 1 3.413-.387m7.5 0V5.25A2.25 2.25 0 0 0 13.5 3h-3a2.25 2.25 0 0 0-2.25 2.25v.894m7.5 0a48.667 48.667 0 0 0-7.5 0M12 12.75h.008v.008H12v-.008Z" /></svg>'.html_safe },
      { id: "projects", label: "Projects", icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5m-9-6h.008v.008H12v-.008ZM12 15h.008v.008H12V15Zm0 2.25h.008v.008H12v-.008ZM9.75 15h.008v.008H9.75V15Zm0 2.25h.008v.008H9.75v-.008ZM7.5 15h.008v.008H7.5V15Zm0 2.25h.008v.008H7.5v-.008Zm6.75-4.5h.008v.008h-.008v-.008Zm0 2.25h.008v.008h-.008V15Zm0 2.25h.008v.008h-.008v-.008Zm2.25-4.5h.008v.008H16.5v-.008Zm0 2.25h.008v.008H16.5V15Z" /></svg>'.html_safe },
      { id: "contact", label: "Contact", icon: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" /></svg>'.html_safe }
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
