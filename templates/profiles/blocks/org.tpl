<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Org::ID}&action=showEditDialog&id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button" ata-iconpos="left">Edit</a>

<button data-role="button" class="cerb-profile-org-contacts">Search contacts</button>

<button data-role="button" class="cerb-profile-org-tickets">Search ticket history</button>

<script type="text/javascript">
$(document).one('pageinit', function() {
	var $page = $(this);
	
	var $btn = $page.find('button.cerb-profile-org-contacts');
	
	$btn.on('click', function() {
		$.mobile.loading('show');
		
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Org::ID}&action=viewSearchContacts&id={$dict->id}{/devblocks_url}',
			function() {
				$.mobile.changePage(
					'{devblocks_url}c=m&a=search&ctx={CerberusContexts::CONTEXT_ADDRESS}{/devblocks_url}',
					{
						transition: 'fade'
					}
				);
			}
		);
	});
	
	var $btn = $page.find('button.cerb-profile-org-tickets');
	
	$btn.on('click', function() {
		$.mobile.loading('show');
		
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_Org::ID}&action=viewSearchTickets&id={$dict->id}{/devblocks_url}',
			function() {
				$.mobile.changePage(
					'{devblocks_url}c=m&a=search&ctx={CerberusContexts::CONTEXT_TICKET}{/devblocks_url}',
					{
						transition: 'fade'
					}
				);
			}
		);
	});
	
});
</script>