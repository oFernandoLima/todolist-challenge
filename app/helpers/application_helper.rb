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

  def user_display_name(user)
    return "" unless user
    if user.respond_to?(:full_name) && user.full_name.present?
      user.full_name
    elsif user.respond_to?(:name) && user.name.present?
      user.name
    else
      user.email
    end
  end
end
