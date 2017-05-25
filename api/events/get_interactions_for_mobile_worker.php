<?php
/***********************************************************************
| Cerb(tm) developed by Webgroup Media, LLC.
|-----------------------------------------------------------------------
| All source code & content (c) Copyright 2002-2017, Webgroup Media LLC
|   unless specifically noted otherwise.
|
| This source code is released under the Devblocks Public License.
| The latest version of this license can be found here:
| http://cerb.ai/license
|
| By using this software, you acknowledge having read this license
| and agree to be bound thereby.
| ______________________________________________________________________
|	http://cerb.ai	    http://webgroup.media
***********************************************************************/

class Event_GetInteractionsForMobileWorker extends Extension_DevblocksEvent {
	const ID = 'event.interactions.get.mobile.worker';
	
	static function getInteractionsByPointAndWorker($point, $point_params, $worker) {
		if(!($point_params instanceof DevblocksDictionaryDelegate) && is_array($point_params))
			$point_params = DevblocksDictionaryDelegate::instance($point_params);
		
		if(!($point_params instanceof DevblocksDictionaryDelegate))
			$point_params = new DevblocksDictionaryDelegate([]);
		
		$behaviors = Event_GetInteractionsForMobileWorker::getByPointAndWorker($point, $worker);
		$interactions = [];
		
		foreach($behaviors as $behavior) { /* @var $behavior Model_TriggerEvent */
			$actions = [];
			
			$event_model = new Model_DevblocksEvent(
				Event_NewInteractionChatMobileWorker::ID,
				array(
					'point' => $point,
					'point_params' => $point_params,
					'worker_id' => $worker->id,
					'actions' => &$actions,
				)
			);
			
			if(false == ($event = $behavior->getEvent()))
				return;
			
			$event->setEvent($event_model, $behavior);
			
			$values = $event->getValues();
			
			$dict = DevblocksDictionaryDelegate::instance($values);
			
			$result = $behavior->runDecisionTree($dict, false, $event);
			
			foreach($actions as $action) {
				switch(@$action['_action']) {
					case 'return.interaction':
						$interactions[] = [
							'label' => $action['name'],
							'behavior_id' => $action['behavior_id'],
							'bot_id' => $action['bot_id'],
							'interaction' => $action['interaction'],
							'params' => is_array($action['interaction_params']) ? $action['interaction_params'] : [],
						];
						break;
				}
			}
		}
		
		return $interactions;
	}
	
	static function getByPointAndWorker($point, $worker) {
		$behaviors = DAO_TriggerEvent::getByEvent(self::ID);
		$behaviors = array_intersect_key(
			$behaviors,
			array_flip(array_keys(Context_TriggerEvent::isReadableByActor($behaviors, $worker), true))
		);
		
		return array_filter($behaviors, function($behavior) use ($point) {
			if(false == (@$listen_points = $behavior->event_params['listen_points']))
				return false;
			
			if(false == ($listen_points = DevblocksPlatform::parseCrlfString($listen_points)) || !is_array($listen_points))
				return false;
			
			if(in_array('*', $listen_points))
				return true;
				
			foreach($listen_points as $listen_point) {
				$regexp = DevblocksPlatform::strToRegExp($listen_point);
				
				if(preg_match($regexp, $point)) {
					return true;
				}
			}
			
			return false;
		});
	}
	
	static function getInteractionMenu(array $interactions) {
		$interactions_menu = [];
		$url_writer = DevblocksPlatform::getUrlService();
		
		if(false == ($bot_ids = array_column($interactions, 'bot_id')))
			return [];
		
		if(false == ($bots = DAO_Bot::getIds($bot_ids)))
			return [];
		
		foreach($bots as $bot) { /* @var $bot Model_Bot */
			$bot_menu = new DevblocksMenuItemPlaceholder();
			$bot_menu->label = $bot->name;
			$bot_menu->image = $url_writer->write(sprintf('c=avatars&context=bot&context_id=%d{/devblocks_url}?v=%s', $bot->id, $bot->updated_at));
			$bot_menu->children = [];
			
			$interactions_menu[$bot->id] = $bot_menu;
		}
		
		foreach($interactions as $interaction) {
			$item_behavior = new DevblocksMenuItemPlaceholder();
			$item_behavior->key = $interaction['behavior_id'];
			$item_behavior->label = $interaction['label'];
			$item_behavior->interaction = $interaction['interaction'];
			$item_behavior->params = $interaction['params'];
			
			$interactions_menu[$interaction['bot_id']]->children[] = $item_behavior;
		}
		
		
		return $interactions_menu;
	}
	
	/**
	 *
	 * @param Model_TriggerEvent $trigger
	 * @return Model_DevblocksEvent
	 */
	function generateSampleEventModel(Model_TriggerEvent $trigger) {
		$actions = [];
		
		$worker = null;
		
		if(false != ($active_worker = CerberusApplication::getActiveWorker()))
			$worker = $active_worker;
		
		return new Model_DevblocksEvent(
			self::ID,
			array(
				'point' => 'example.point',
				'point_params' => ["key1" => "val1", "key2" => "val2"],
				'worker' => $worker,
				'actions' => &$actions,
			)
		);
	}
	
	function setEvent(Model_DevblocksEvent $event_model=null, Model_TriggerEvent $trigger=null) {
		$labels = array();
		$values = array();
		
		/**
		 * Behavior
		 */
		
		$merge_labels = array();
		$merge_values = array();
		CerberusContexts::getContext(CerberusContexts::CONTEXT_BEHAVIOR, $trigger, $merge_labels, $merge_values, null, true);

			// Merge
			CerberusContexts::merge(
				'behavior_',
				'',
				$merge_labels,
				$merge_values,
				$labels,
				$values
			);
		
		// Interaction
		@$point = $event_model->params['point'];
		$labels['point'] = 'Interaction Point';
		$values['point'] = $point;
		
		@$point_params = $event_model->params['point_params'];
		$labels['point_params'] = 'Interaction Point Parameters';
		$values['point_params'] = ($point_params instanceof DevblocksDictionaryDelegate) ? $point_params : new DevblocksDictionaryDelegate([]);
		
		// Actions
		$values['_actions'] =& $event_model->params['actions'];

		/**
		 * Worker
		 */
		
		@$worker_id = $event_model->params['worker_id'];
		
		$merge_labels = array();
		$merge_values = array();
		CerberusContexts::getContext(CerberusContexts::CONTEXT_WORKER, $worker_id, $merge_labels, $merge_values, null, true);

			// Merge
			CerberusContexts::merge(
				'worker_',
				'',
				$merge_labels,
				$merge_values,
				$labels,
				$values
			);
		
		/**
		 * Return
		 */

		$this->setLabels($labels);
		$this->setValues($values);
	}
	
	function getValuesContexts($trigger) {
		$vals = array(
			'behavior_id' => array(
				'label' => 'Behavior',
				'context' => CerberusContexts::CONTEXT_BEHAVIOR,
			),
			'behavior_bot_id' => array(
				'label' => 'Behavior',
				'context' => CerberusContexts::CONTEXT_BOT,
			),
			'worker_id' => array(
				'label' => 'Sender',
				'context' => CerberusContexts::CONTEXT_WORKER,
			),
		);
		
		$vars = parent::getValuesContexts($trigger);
		
		$vals_to_ctx = array_merge($vals, $vars);
		DevblocksPlatform::sortObjects($vals_to_ctx, '[label]');
		
		return $vals_to_ctx;
	}
	
	function renderEventParams(Model_TriggerEvent $trigger=null) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('trigger', $trigger);
		
		$tpl->display('devblocks:cerberusweb.core::events/interaction/params_interactions_get_for_worker.tpl');
	}
	
	function getConditionExtensions(Model_TriggerEvent $trigger) {
		$labels = $this->getLabels($trigger);
		$types = $this->getTypes();
		
		$types['point'] = Model_CustomField::TYPE_SINGLE_LINE;
		$types['point_params'] = null;
		
		$conditions = $this->_importLabelsTypesAsConditions($labels, $types);
		
		return $conditions;
	}
	
	function renderConditionExtension($token, $as_token, $trigger, $params=array(), $seq=null) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('params', $params);

		if(!is_null($seq))
			$tpl->assign('namePrefix','condition'.$seq);
		
		switch($as_token) {
		}

		$tpl->clearAssign('namePrefix');
		$tpl->clearAssign('params');
	}
	
	function runConditionExtension($token, $as_token, $trigger, $params, DevblocksDictionaryDelegate $dict) {
		$pass = true;
		
		switch($as_token) {
			default:
				$pass = false;
				break;
		}
		
		return $pass;
	}
	
	function getActionExtensions(Model_TriggerEvent $trigger) {
		$actions =
			array(
				'return_interaction' => array('label' => 'Return interaction'),
			)
		;
		
		return $actions;
	}
	
	function renderActionExtension($token, $trigger, $params=array(), $seq=null) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('params', $params);

		if(!is_null($seq))
			$tpl->assign('namePrefix','action'.$seq);

		$labels = $this->getLabels($trigger);
		$tpl->assign('token_labels', $labels);
			
		switch($token) {
			case 'return_interaction':
				$tpl->assign('event_point', Event_NewInteractionChatMobileWorker::ID);
				$tpl->display('devblocks:cerberusweb.core::events/interaction/action_return_interaction.tpl');
				break;
		}
		
		$tpl->clearAssign('params');
		$tpl->clearAssign('namePrefix');
		$tpl->clearAssign('token_labels');
	}
	
	function simulateActionExtension($token, $trigger, $params, DevblocksDictionaryDelegate $dict) {
		switch($token) {
			case 'return_interaction':
				$tpl_builder = DevblocksPlatform::getTemplateBuilder();
				
				@$behavior_id = intval($params['behavior_id']);
				
				if(false == ($behavior = DAO_TriggerEvent::get($behavior_id)))
					break;
				
				@$name = $tpl_builder->build($params['name'], $dict);
				@$interaction = $tpl_builder->build($params['interaction'], $dict);
				
				if(empty($name) || empty($interaction))
					break;
				
				@$interaction_params_json = $tpl_builder->build($params['interaction_params_json'], $dict);
				if(false == ($interaction_params = json_decode($interaction_params_json, true)))
					$interaction_params = [];
				
				$out = sprintf(">>> Returning interaction\n".
					"%d\n",
					$behavior_id
				);
				break;
		}
		
		return $out;
	}
	
	function runActionExtension($token, $trigger, $params, DevblocksDictionaryDelegate $dict) {
		switch($token) {
			case 'return_interaction':
				$tpl_builder = DevblocksPlatform::getTemplateBuilder();
				
				$actions =& $dict->_actions;
				
				@$behavior_id = intval($params['behavior_id']);
				
				if(false == ($behavior = DAO_TriggerEvent::get($behavior_id)))
					break;
				
				@$name = $tpl_builder->build($params['name'], $dict);
				@$interaction = $tpl_builder->build($params['interaction'], $dict);
				
				if(empty($name) || empty($interaction))
					break;
				
				@$interaction_params_json = $tpl_builder->build($params['interaction_params_json'], $dict);
				if(false == ($interaction_params = json_decode($interaction_params_json, true)))
					$interaction_params = [];
				
				// Sanitize key names and values
				
				$keys = array_map(function($key) {
					return DevblocksPlatform::strAlphaNum($key, '-');
					}, array_keys($interaction_params)
				);
				
				$vals = array_map(function($val) {
					if(!is_string($val))
						$val = strval($val);
					
					$val = trim($val);
					return $val;
					}, $interaction_params
				);
				
				$interaction_params = array_combine($keys, $vals);
				
				$actions[] = [
					'_action' => 'return.interaction',
					'behavior_id' => $behavior_id,
					'bot_id' => $behavior->bot_id,
					'name' => $name,
					'interaction' => $interaction,
					'interaction_params' => $interaction_params,
				];
				break;
		}
	}
};
