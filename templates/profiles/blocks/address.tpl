<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_EmailAddress::ID}&action=showEditDialog&id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button">Edit</a>

<a href="{devblocks_url}c=m&a=compose{/devblocks_url}?to={$dict->address}" data-role="button" class="cerb-profile-addy-compose">Compose</a>

<button data-role="button" class="cerb-profile-addy-tickets">Search ticket history</button>

<script type="text/javascript">
$(document).one('pageinit', function() {
	var $page = $(this);
	var $btn = $page.find('button.cerb-profile-addy-tickets');
	
	$btn.on('click', function() {
		$.mobile.loading('show');
		
		$.get(
			'{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_EmailAddress::ID}&action=viewSearchTickets&id={$dict->id}{/devblocks_url}',
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