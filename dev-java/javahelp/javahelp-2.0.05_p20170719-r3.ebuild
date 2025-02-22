# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="3ca862d8626096770598a3a256886d205246f4a4"
JAVA_PKG_IUSE="examples source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="The JavaHelp system online help system"
HOMEPAGE="https://javaee.github.io/javahelp/"
SRC_URI="https://github.com/javaee/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"

CDEPEND="
	dev-java/javax-jsp-api:2.0
	dev-java/javax-servlet-api:2.5
"

RDEPEND=">=virtual/jre-1.8:*
	${CDEPEND}"

DEPEND="virtual/jdk:1.8
	${CDEPEND}"

JAVA_PKG_NV_DEPEND="virtual/jdk:1.8"

S="${WORKDIR}/${PN}-${COMMIT}"

_eant() {
	local \
		servlet_jar=$(java-pkg_getjars javax-servlet-api-2.5) \
		jsp_jar=$(java-pkg_getjars javax-jsp-api-2.0)

	eant \
		-f javahelp_nbproject/build.xml \
		-Dfile.reference.servlet-api.jar="${servlet_jar}" \
		-Dfile.reference.jsp-api.jar="${jsp_jar}" \
		-Dservlet-jar="${servlet_jar}" \
		-Djsp-jar="${jsp_jar}" \
		-Dservlet-jar-present=true \
		-Djsp-jar-present=true \
		-Dtomcat-zip-present=true \
		${@}
}

src_compile() {
	_eant release
}

#Does not actually run anything
#src_test() {
#	_eant test
#}

src_install() {
	java-pkg_dojar javahelp_nbproject/dist/lib/*.jar

	java-pkg_dolauncher jhsearch \
		--main com.sun.java.help.search.QueryEngine
	java-pkg_dolauncher jhindexer \
		--main com.sun.java.help.search.Indexer

	use source && java-pkg_dosrc \
		jhMaster/JSearch/*/com \
		jhMaster/JavaHelp/src/*/{javax,com}

	use examples && java-pkg_doexamples jhMaster/JavaHelp/demos
}
