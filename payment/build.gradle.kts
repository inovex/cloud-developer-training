import jp.classmethod.aws.gradle.s3.AmazonS3FileUploadTask
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	val kotlinVersion = "1.3.21"
	id("org.springframework.boot") version "2.1.4.RELEASE"
	id("org.jetbrains.kotlin.jvm") version kotlinVersion
	id("org.jetbrains.kotlin.plugin.spring") version kotlinVersion
	id("io.spring.dependency-management") version "1.0.7.RELEASE"
	id("org.jetbrains.gradle.plugin.idea-ext") version "0.5"
	id("jp.classmethod.aws.s3") version "0.39"
}

repositories {
	mavenCentral()
	jcenter()
}

group = "de.inovex.training.whiskystore.payment"
version = "0.0.1-SNAPSHOT"

tasks.withType<KotlinCompile> {
	kotlinOptions {
		jvmTarget = "1.8"
		freeCompilerArgs = listOf("-Xjsr305=strict")
	}
}

dependencies {
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.jetbrains.kotlin:kotlin-reflect")

	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.boot:spring-boot-starter-actuator")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("com.fasterxml.jackson.datatype:jackson-datatype-jdk8")

	testImplementation("org.springframework.boot:spring-boot-starter-test")
}

aws {
	profileName = "javaland"
	region = "eu-central-1"
}

tasks.create<AmazonS3FileUploadTask>("uploadToS3") {
	dependsOn("build")
	//overwrite = true
	file = tasks.getByName<Jar>("jar").archiveFile.get().asFile
	bucketName = "javaland-whiskystore-terraform"
	key = "${project.rootProject.properties["userPrefix"]}/jars/payment/${tasks.getByName<Jar>("jar").archiveFileName}"
}

tasks.create<GradleBuild>("buildAndDeploy") {
	tasks = listOf("clean", "uploadToS3", "deploy")
}
