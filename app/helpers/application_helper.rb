module ApplicationHelper
  def confirm_message(record)
    case record
    when TaskList
      "Excluir a lista '#{record.name}' e TODAS as tarefas? Ação irreversível."
    when Task
      "Excluir a tarefa '#{record.title}'?"
    else
      "Tem certeza?"
    end
  end
end
