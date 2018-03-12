package de.inovex.training.whiskystore.imagescaler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.S3Event;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.event.S3EventNotification;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;
import net.coobird.thumbnailator.Thumbnails;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

public class ImageScaler implements RequestHandler<S3Event, Void> {

    private AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
            .withRegion(System.getProperty("REGION", "eu-central-1"))
            .build();

    private static final String INBOX = "inbox/";
    private static final String OUTPUT = "output/";
    private static final String THUMBNAIL = "-thumbail.";


    @Override
    public Void handleRequest(S3Event event, Context context) {

        System.out.println("Image Scaler triggered");

        S3EventNotification.S3EventNotificationRecord record = event.getRecords().get(0);

        try (S3Object s3Object = getOriginalImage(record)) {

            String key = getKey(record);

            if (key != null) {

                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

                Thumbnails.of(s3Object.getObjectContent())
                        .size(120, 120)
                        .outputFormat("JPEG")
                        .toOutputStream(outputStream);

                storeThumbnail(record, outputStream.toByteArray());

                copyOriginalToOutputFolder(record);
            }

            return null;
        } catch (Exception e) {
            System.out.println(e);
            return null;
        }
    }

    private S3Object getOriginalImage(S3EventNotification.S3EventNotificationRecord record) {
        String srcBucket = record.getS3().getBucket().getName();
        // Download the image from S3 into a stream
        return s3Client.getObject(new GetObjectRequest(srcBucket, getKey(record)));
    }

    private void copyOriginalToOutputFolder(S3EventNotification.S3EventNotificationRecord record) {
        s3Client.copyObject(record.getS3().getBucket().getName(), getKey(record),
                record.getS3().getBucket().getName(), getKey(record).replaceAll(INBOX, OUTPUT));
    }

    private void storeThumbnail(S3EventNotification.S3EventNotificationRecord record, byte[] imageBytes) {
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(imageBytes.length);
        metadata.setContentType("image/jpeg");

        String key = getKey(record);
        int lastIndex = key.lastIndexOf(".");

        if (lastIndex != -1) {
            String path = key.substring(0, lastIndex);
            String extension = key.substring(lastIndex + 1);
            key = path + THUMBNAIL + extension;
        }

        key = key.replaceAll(INBOX, OUTPUT);

        s3Client.putObject(record.getS3().getBucket().getName(), key, new ByteArrayInputStream(imageBytes), metadata);
    }

    private String getKey(S3EventNotification.S3EventNotificationRecord record) {
        try {
            // Object key may have spaces or unicode non-ASCII characters.
            String srcKey = record.getS3().getObject().getKey().replace('+', ' ');
            return URLDecoder.decode(srcKey, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            System.out.println(e);
            return null;
        }
    }

}
