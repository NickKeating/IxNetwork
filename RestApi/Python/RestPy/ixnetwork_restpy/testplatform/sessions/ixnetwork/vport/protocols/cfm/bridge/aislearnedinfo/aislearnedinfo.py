from ixnetwork_restpy.base import Base
from ixnetwork_restpy.files import Files


class AisLearnedInfo(Base):
	"""The AisLearnedInfo class encapsulates a system managed aisLearnedInfo node in the ixnetwork hierarchy.

	An instance of the class can be obtained by accessing the AisLearnedInfo property from a parent instance.
	The internal properties list will be empty when the property is accessed and is populated from the server by using the find method.
	"""

	_SDM_NAME = 'aisLearnedInfo'

	def __init__(self, parent):
		super(AisLearnedInfo, self).__init__(parent)

	@property
	def BVlan(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('bVlan')

	@property
	def CVlan(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('cVlan')

	@property
	def MepMacAddress(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('mepMacAddress')

	@property
	def RemoteMepMacAddress(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('remoteMepMacAddress')

	@property
	def RxCount(self):
		"""NOT DEFINED

		Returns:
			number
		"""
		return self._get_attribute('rxCount')

	@property
	def RxInterval(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('rxInterval')

	@property
	def RxState(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('rxState')

	@property
	def SVlan(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('sVlan')

	@property
	def TxCount(self):
		"""NOT DEFINED

		Returns:
			number
		"""
		return self._get_attribute('txCount')

	@property
	def TxState(self):
		"""NOT DEFINED

		Returns:
			str
		"""
		return self._get_attribute('txState')

	def find(self, BVlan=None, CVlan=None, MepMacAddress=None, RemoteMepMacAddress=None, RxCount=None, RxInterval=None, RxState=None, SVlan=None, TxCount=None, TxState=None):
		"""Finds and retrieves aisLearnedInfo data from the server.

		All named parameters support regex and can be used to selectively retrieve aisLearnedInfo data from the server.
		By default the find method takes no parameters and will retrieve all aisLearnedInfo data from the server.

		Args:
			BVlan (str): NOT DEFINED
			CVlan (str): NOT DEFINED
			MepMacAddress (str): NOT DEFINED
			RemoteMepMacAddress (str): NOT DEFINED
			RxCount (number): NOT DEFINED
			RxInterval (str): NOT DEFINED
			RxState (str): NOT DEFINED
			SVlan (str): NOT DEFINED
			TxCount (number): NOT DEFINED
			TxState (str): NOT DEFINED

		Returns:
			self: This instance with matching aisLearnedInfo data retrieved from the server available through an iterator or index

		Raises:
			ServerError: The server has encountered an uncategorized error condition
		"""
		return self._select(locals())

	def read(self, href):
		"""Retrieves a single instance of aisLearnedInfo data from the server.

		Args:
			href (str): An href to the instance to be retrieved

		Returns:
			self: This instance with the aisLearnedInfo data from the server available through an iterator or index

		Raises:
			NotFoundError: The requested resource does not exist on the server
			ServerError: The server has encountered an uncategorized error condition
		"""
		return self._read(href)