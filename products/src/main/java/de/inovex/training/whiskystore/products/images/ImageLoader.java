package de.inovex.training.whiskystore.products.images;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.io.support.ResourcePatternUtils;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Component
public class ImageLoader {

    private final AmazonS3 s3Client;
    private final String s3Bucket;
    private final String s3Prefix;

    private final ResourceLoader resourceLoader;

    @Autowired
    public ImageLoader(@Value("${aws.s3.bucket:}") String s3Bucket,
                       @Value("${aws.s3.region:}") String s3Region,
                       @Value("${aws.s3.prefix:}") String s3Prefix,
                       ResourceLoader resourceLoader) {
        this.s3Bucket = s3Bucket;
        this.s3Prefix = s3Prefix;

        if (StringUtils.isEmpty(s3Bucket) || StringUtils.isEmpty(s3Prefix) || StringUtils.isEmpty(s3Region)) {
            this.s3Client = null;
        } else {
            this.s3Client = AmazonS3ClientBuilder.standard()
                    .withRegion(s3Region)
                    .build();
        }

        this.resourceLoader = resourceLoader;
    }

    public List<ProductImage> loadImagesForProduct(long productId) {
        if (s3Client != null) {
            return loadImagesFromS3(productId);
        } else {
            return loadImagesFromClasspath(productId);
        }
    }

    private List<ProductImage> loadImagesFromS3(long productId) {
        List<ProductImage> images = new ArrayList<>();

        ObjectListing imageObjects = s3Client.listObjects(s3Bucket, s3Prefix + "/" + productId + "/");

        for (S3ObjectSummary imageObject : imageObjects.getObjectSummaries()) {
            images.add(new ProductImage(imageObject.getKey()));
        }

        return images;
    }

    private List<ProductImage> loadImagesFromClasspath(long productId) {
        List<ProductImage> images = new ArrayList<>();
        try {
            Resource[] imageResources = ResourcePatternUtils.getResourcePatternResolver(resourceLoader).getResources("classpath:/images/" + productId + "/*.jpg");

            for (Resource imageResource : imageResources) {
                images.add(new ProductImage(imageResource.getFilename()));
            }

            return images;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

}
