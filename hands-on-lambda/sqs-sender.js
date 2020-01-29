const aws = require('aws-sdk');
aws.config.update({region: 'eu-central-1'});

const sqs = new aws.SQS({apiVersion: '2012-11-05'});

exports.handler = async (event) => {
    const msg = event.queryStringParameters ? event.queryStringParameters.msg : "UNKNOWN";

    console.log('Found message: ' + msg)

    var params = {
        MessageBody: msg,
        QueueUrl: '<your-queue-url>'
    };

    console.log('Trying to send: ' + params)

    var response;

    await sqs.sendMessage(params, function(err, data) {
        if (err) {
            console.log("Error", err);
            response = {
                statusCode: 500,
                body: JSON.stringify('Failed to send message: ' + msg),
            };
        } else {
            console.log("Success", data.MessageId);
            response = {
                statusCode: 200,
                body: JSON.stringify('Successfully sent message: ' + msg),
            };
        }
    }).promise();

    return response;
};
