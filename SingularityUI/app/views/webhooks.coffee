View = require './view'

Webhooks = require '../collections/Webhooks'

class WebhooksView extends View

    template: require './templates/webhooks'

    initialize: =>
        @webhooks = new Webhooks

        @webhooks.fetch().done =>
            @fetchDone = true
            @render()

        @webhooks.on 'add remove', => @render()

    render: =>
        return unless @fetchDone

        @$el.html @template webhooks: _.pluck(@webhooks.models, 'attributes')

        @setupEvents()

        utils.setupSortableTables()

    setupEvents: ->
        $addInput = @$el.find('input[type="search"]')

        $addInput.unbind().on 'keypress', (e) =>
            if e.keyCode is 13
                _.each $addInput.val().split(/,? +/), (url) =>
                    @webhooks.create url: url

        $removeLinks = @$el.find('[data-action="remove"]')

        $removeLinks.unbind('click').on 'click', (e) =>
            webhookModel = @webhooks.find((w) -> w.get('url') is $(e.target).data('url'))

            vex.dialog.confirm
                message: "<p>Are you sure you want to delete the webhook:</p><pre>#{ webhookModel.get('url') }</pre>"
                callback: (confirmed) =>
                    return unless confirmed
                    webhookModel.destroy()
                    @webhooks.remove(webhookModel)

module.exports = WebhooksView