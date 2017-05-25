{$msg_id = uniqid()}
<div class="bot-chat-object" id="{$msg_id}" data-delay-ms="{$delay_ms|default:0}">
	<script type="text/javascript">
	$(function() {
		var $msg = $('#{$msg_id}');
		var $chat_window_input_form = $msg.closest('form');
		var $convo = $chat_window_input_form.find('.bot-chat-window-convo');
		var $chat_input = $chat_window_input_form.find('input[name=message]');
		
		var cb = function() {
			$chat_input.val('');
			$chat_window_input_form.submit();
			$convo.trigger('cerb-send-message');
		}
		
		setTimeout(cb, 250);
	});
	</script>
</div>
