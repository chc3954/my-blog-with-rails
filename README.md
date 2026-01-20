# My Blog with Rails

A modern, high-performance blog application built with **Ruby on Rails 8**, utilizing **Notion** as a headless CMS.

[**Live Demo: https://hyunchul.me**](https://hyunchul.me)

<img width="2334" height="1936" alt="image" src="https://github.com/user-attachments/assets/f64f40c1-8a33-4ac6-8338-a357e8e5080e" />


## 🚀 Features

- **Notion Integration**: Write your posts in Notion, and they automatically sync to your blog.
- **Smart Sync**: Efficient synchronization logic that only updates changed posts based on `last_edited_time`.
- **Modern UI**: Built with **Tailwind CSS**, featuring responsive design, dark mode support, and a clean reading experience.
- **Performance Optimization**:
  - **Database-Level Filtering**: Optimized SQLite JSON queries for tag filtering.
  - **Image Optimization**: Automatic thumbnail generation using `image_processing` (libvips) to reduce load times.
  - **Caching**: Fragment caching for static content like tag lists.
  - **Indexing**: Optimized database indexes for fast sorting and retrieval.

## 🛠 Tech Stack

- **Framework**: Ruby on Rails 8.0
- **Database**: SQLite (Production-ready in Rails 8)
- **Frontend**: Hotwire (Turbo & Stimulus), Tailwind CSS
- **CMS**: Notion API (`notion-ruby-client`)
- **Utilities**: `image_processing` (ActiveStorage variants)

## 📋 Prerequisites

- Ruby 3.2+
- SQLite3
- **Libvips** (Required for image processing)
  - macOS: `brew install vips`
  - Ubuntu: `sudo apt install libvips-dev`

## ⚙️ Configuration

Set the following environment variables (using `.env`, `direnv`, or system env):

```bash
# Notion Integration
NOTION_TOKEN=secret_your_integration_token
NOTION_DATABASE_ID=your_database_id
```

## 🚀 Getting Started

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/yourusername/my-blog-with-rails.git
    cd my-blog-with-rails
    ```

2.  **Install dependencies**:

    ```bash
    bundle install
    ```

3.  **Setup Database**:

    ```bash
    rails db:setup
    ```

4.  **Run the Server**:
    ```bash
    ./bin/dev
    ```
    Visit `http://localhost:3000` to see the blog.

## 🔄 Syncing Posts

To sync posts from your Notion database:

```bash
# Run the sync service manually via Rails Runner
rails runner "NotionSyncService.new.sync_posts"
```

You can set this up as a cron job or scheduled task for automatic updates.

---

### 📝 License

MIT License
