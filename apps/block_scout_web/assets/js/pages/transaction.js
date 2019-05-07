import $ from 'jquery'
import _ from 'lodash'
import humps from 'humps'
import numeral from 'numeral'
import socket from '../socket'
import { createStore, connectElements } from '../lib/redux_helpers.js'

export const initialState = {
  blockNumber: null,
  confirmations: null
}

export function reducer (state = initialState, action) {
  switch (action.type) {
    case 'ELEMENTS_LOAD': {
      return Object.assign({}, state, _.omit(action, 'type'))
    }
    case 'RECEIVED_NEW_BLOCK': {
      if ((action.msg.blockNumber - state.blockNumber) > state.confirmations) {
        return Object.assign({}, state, {
          confirmations: action.msg.blockNumber - state.blockNumber
        })
      } else return state
    }
    default:
      return state
  }
}

const elements = {
  '[data-selector="block-number"]': {
    load ($el) {
      return { blockNumber: parseInt($el.text(), 10) }
    }
  },
  '[data-selector="block-confirmations"]': {
    render ($el, state, oldState) {
      if (oldState.confirmations !== state.confirmations) {
        $el.empty().append(numeral(state.confirmations).format())
      }
    }
  }
}

const $transactionDetailsPage = $('[data-page="transaction-details"]')
if ($transactionDetailsPage.length) {
  const store = createStore(reducer)
  connectElements({ store, elements })

  const blocksChannel = socket.channel(`blocks:new_block`, {})
  blocksChannel.join()
  blocksChannel.on('new_block', (msg) => store.dispatch({
    type: 'RECEIVED_NEW_BLOCK',
    msg: humps.camelizeKeys(msg)
  }))

  const transactionHash = $transactionDetailsPage[0].dataset.pageTransactionHash
  const transactionChannel = socket.channel(`transactions:${transactionHash}`, {})
  transactionChannel.join()
  transactionChannel.on('collated', () => window.location.reload())
}



//Code that needs to be applied starts here

$(document).ready(function(){
  
  $("#viewDetailsIcon i, #viewDetails").click(function(){
    $(".blockchainDetailsContentParent").slideToggle("slow");
  });

  $(".blockchainViewDetailsParent").click(function(){
    $("#viewDetailsIcon i").toggleClass("rotate"); 
   });

  $("#viewDetailsIcon i").click(function(){
    $("#viewDetails").text($("#viewDetails").text() == 'View Details' ? 'Hide Details' : 'View Details');
  });
  
});

$(document).ready(function(){
  $("#inputviewDetailsIcon i, #inputViewDetails").click(function(){
    $(".blockchainInputContent").slideToggle("slow");
  });

  $(".inputViewDetailsParent").click(function(){
    $("#inputviewDetailsIcon i").toggleClass("rotate"); 
   });

  $("#inputviewDetailsIcon i").click(function(){
    $("#inputViewDetails").text($("#inputViewDetails").text() == 'View Details' ? 'Hide Details' : 'View Details');
  });

});

$(document).ready(function(){
  $("#LogviewDetailsIcon i, #logviewDetails").click(function(){
    $(".blockchianLogAddress").slideToggle("slow");
  });

  $(".logViewDetailsParent").click(function(){
    $("#LogviewDetailsIcon i").toggleClass("rotate"); 
   });

   $("#LogviewDetailsIcon i").click(function(){
    $("#logviewDetails").text($("#logviewDetails").text() == 'View Details' ? 'Hide Details' : 'View Details');
  });

});

$(document).ready(function(){
  $(".dark-blue-text i").click(function(){
    $(".blockchainDetailsContentParent").slideToggle("slow");
  });

  $("#viewDetails").click(function(){
    $(this).text($(this).text() == 'View Details' ? 'Hide Details' : 'View Details');
  });
});

$('.dark-blue-text i').click(function() {
  $(this).toggleClass("fa-times");
});  
//Code that needs to be applied ends here