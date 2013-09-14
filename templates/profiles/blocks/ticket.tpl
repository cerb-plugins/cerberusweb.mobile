<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=showEditDialog&id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button" ata-iconpos="left">Edit</a>

<h3 style="margin-top:10px;margin-bottom:10px;">Messages</h3>

<div style="font-size:12px;" class="cerb-profile-ticket-message">
	{CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $dict->latest_message_id, $message_labels, $message_values)}
	{$message_dict = DevblocksDictionaryDelegate::instance($message_values)}
	{include file="devblocks:cerberusweb.mobile::profiles/blocks/ticket/message.tpl" dict=$message_dict}
</div>

<button data-role="button" class="cerb-profile-ticket-view-history">Search messages</button>

<script type="text/javascript">
var $page = $('#page-profile-{$context|replace:'.':''}-{$context_id}');

$page.on('pageinit', function() {
	var $page = $(this);
	
	var $btn_view_history = $page.find('button.cerb-profile-ticket-view-history');
	
	$btn_view_history.on('click', function() {
		$.mobile.loading('show');
		
		$.get(
			'{devblocks_url}c=m&a=handleProfileBlockRequest&extension={MobileProfile_Ticket::ID}&action=viewSearchMessages&ticket_id={$dict->id}{/devblocks_url}',
			function() {
				$.mobile.changePage(
					'{devblocks_url}c=m&a=search&ctx={CerberusContexts::CONTEXT_MESSAGE}{/devblocks_url}',
					{
						transition: 'fade'
					}
				);
			}
		);
	});
});
</script>