import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	val kotlinVersion = "1.3.21"
	id("org.springframework.boot") version "2.1.4.RELEASE"
	id("org.jetbrains.kotlin.jvm") version kotlinVersion
	id("org.jetbrains.kotlin.plugin.spring") version kotlinVersion
	id("io.spring.dependency-management") version "1.0.7.RELEASE"
	id("org.jetbrains.gradle.plugin.idea-ext") version "0.5"
	id("com.google.cloud.tools.jib") version "1.1.2"
}

repositories {
	mavenCentral()
	jcenter()
}

group = "de.inovex.training.whiskystore.payment"
version = file("VERSION").readText().trim()

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

jib {
	to {
		image = "853161928370.dkr.ecr.eu-central-1.amazonaws.com/${project.property("userPrefix")}-payment"
		tags = setOf("${project.version}")
	}
}

val awsECRLogin = task<Exec>("awsECRLogin") {
	standardInput = System.`in`
	executable = "sh"
	setArgs(listOf("-c", "aws ecr get-login --region eu-central-1 --no-include-email | sh -"))
}

tasks {
	"jib" {
		dependsOn(awsECRLogin)
	}
}

task<Exec>("bumpVersion") {
	executable = "sh"
	setArgs(listOf("-c", "date +%s > VERSION"))
}

tasks.create<GradleBuild>("buildAndDeploy") {
	tasks = listOf("clean", "build", "jib", "deploy")
}