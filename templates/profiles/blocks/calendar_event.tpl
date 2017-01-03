{$calendar = DAO_Calendar::get($dict->calendar_id)}
{if $calendar && Context_Calendar::isWriteableByActor($calendar, $active_worker) && empty($calendar->params.manual_disabled)}
<a href="{devblocks_url}ajax.php?c=m&a=handleProfileBlockRequest&extension={MobileProfile_CalendarEvent::ID}&action=showEditDialog&id={$dict->id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button">Edit</a>
{/if}