console.log('Loading function');

const aws = require('aws-sdk');
const s3 = new aws.S3({ apiVersion: '2006-03-01' });

exports.handler = async (event) => {
    for (const { messageId, body } of event.Records) {
        console.log('SQS message %s: %j', messageId, body);

        var params = {
            Body: body,
            Bucket: '<your-bucket-name>',
            Key: new Date().toISOString() + '.txt'
        };

        await s3.putObject(params, function(err, data) {
            if (err) console.log(err, err.stack);
            else console.log(data);
        }).promise();
    }
    return `Successfully processed ${event.Records.length} messages.`;
};
