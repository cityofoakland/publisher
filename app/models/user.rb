require "user"

class User
  alias_method :record_action_without_noise, :record_action

  def record_action(*args)
    record_action_without_noise *args
    Messenger.instance.send messenger_topic, edition unless messenger_topic == "created"
    NoisyWorkflow.make_noise(action).deliver
    NoisyWorkflow.request_fact_check(action).deliver if type == "send_fact_check"
  end
end
