# ToDoList Challenge

Aplicação Rails para gestão de listas de tarefas colaborativas com controle de permissões.

## Stack
- Ruby 3.4.5
- Rails 8.0.2.1
- PostgreSQL 
- Bootstrap 5
- Turbo / Hotwire

## Funcionalidades
- CRUD de Listas de Tarefas
- Tarefas com: título, descrição, prioridade, status (todo / doing / done)
- Kanban simples (arrastar e soltar altera status via AJAX)
- Sistema de colaboração por convites
- Permissões por colaborador (viewer, editor, admin)

## Modelos Principais
TaskList
Task
TaskListCollaborator
User

## Permissões (Resumo)
| Papel        | Ver | Editar Tarefas | Excluir Tarefas | Gerir Colaboradores |
|--------------|-----|----------------|-----------------|---------------------|
| Proprietário | ✔   | ✔              | ✔               | ✔                   |
| Admin        | ✔   | ✔              | ✔               | ✔                   |
| Editor       | ✔   | ✔              | ✔               | ✖                   |
| Viewer       | ✔   | ✖              | ✖               | ✖                   |

## Instalação
```bash
git clone https://github.com/oFernandoLima/todolist-challenge.git
cd todolist-challenge
bundle install
bin/rails db:setup
bin/rails server
```

Acesse: http://localhost:3000

## Variáveis de Ambiente (exemplos)
- TODOLIST_CHALLENGE_DATABASE_PASSWORD=password (desenvolvimento)