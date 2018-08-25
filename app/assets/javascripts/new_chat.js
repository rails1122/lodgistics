$(".new-chat").ready(function() {
  let selected_user_ids = []
  const current_url = new URL(location.href);
  const is_private = current_url.searchParams.get('is_private');

  $(".new-chat-title").on('input', function() {
    update_create_new_chat_btn();
  });

  $(".new-chat-user").click(function() {
    $(this).toggleClass('selected-new-chat-user');
    const user_id = $(this).data("userId");
    const should_add_user_id = $(this).hasClass('selected-new-chat-user');

    update_selected_user_ids(user_id, should_add_user_id);
    update_create_new_chat_btn();
  });

  $(".create-new-chat-btn").click(function() {
    const url = "/chats.json";
    const title = $(".new-chat-title").val();
    const chat_param = { name: title, user_ids: selected_user_ids, is_private: is_private };
    $.post(url, { chat: chat_param })
      .done(function(data) {
        alert('New Chat created!')
        const id = data.id;
        window.location.href = `/messages/${id}`
      }).fail(function(xhr, status, error) {
        alert('Error!')
      });
  });

  function update_selected_user_ids(user_id, should_add_user_id) {
    if (should_add_user_id) {
      selected_user_ids.push(user_id);
    } else {
      selected_user_ids = selected_user_ids.filter(function(e) {
        return e != user_id
      });
    }
  }

  function update_create_new_chat_btn() {
    let disabled = (selected_user_ids.length == 0);
    if (is_private) {
      const title = $(".new-chat-title").val();
      disabled = disabled || (title == '');
    }
    $(".create-new-chat-btn").prop('disabled', disabled);
  }

});


